#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql.h>
#include <Windows.h>

#include "defines.h"


typedef enum {
	GIOCATORE = 1,
	MODERATORE,
	FAILED_LOGIN
} role_t;

#define DIM 46

struct configuration conf;

static MYSQL* conn;

/*Funzione che mi permettera' tramite prepared statement di invocare la store procedure login*/
static role_t attempt_login(MYSQL* conn, char* username, char* password) {
	MYSQL_STMT* login_procedure; /*Struttura del C connector*/

	/*3 sono i parametri che dobbiamo passare alla store procedure login, quindi dovro' fare 3 binding*/
	MYSQL_BIND param[3]; // Used both for input and output
	int role = 0;

	/*setup_prepared_stmt e' definita in utils.c*/
	if (!setup_prepared_stmt(&login_procedure, "call login(?, ?, ?)", conn)) {
		print_stmt_error(login_procedure, "Unable to initialize login statement\n");
		goto err2;
	}

	// Prepare parameters
	/*Binding di tutti i parametri da passare, sia gli in che gli out*/
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = username;
	param[0].buffer_length = strlen(username);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[1].buffer = password;
	param[1].buffer_length = strlen(password);

	param[2].buffer_type = MYSQL_TYPE_LONG; // OUT
	param[2].buffer = &role;
	param[2].buffer_length = sizeof(role);

	if (mysql_stmt_bind_param(login_procedure, param) != 0) { // Note _param
		print_stmt_error(login_procedure, "Could not bind parameters for login");
		goto err;
	}

	// Run procedure 
	/*Invio i parametri al DBMS*/
	if (mysql_stmt_execute(login_procedure) != 0) {
		print_stmt_error(login_procedure, "Could not execute login procedure");
		goto err;
	}

	// Prepare output parameters
	/*Binding al contrario per ottenere dal DBMS il parametro out della procedura login*/
	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_LONG; // OUT
	param[0].buffer = &role;
	param[0].buffer_length = sizeof(role);

	if (mysql_stmt_bind_result(login_procedure, param)) {
		print_stmt_error(login_procedure, "Could not retrieve output parameter");
		goto err;
	}

	// Retrieve output parameter
	/*Estraggo il parametro out dal result set, che in questo caso e' una tabella 1x1*/
	if (mysql_stmt_fetch(login_procedure)) {
		print_stmt_error(login_procedure, "Could not buffer results");
		goto err;
	}

	/*Chiudo lo statement e restituisco il ruolo (che sara' un intero che viene castato a role_t che e' una enum)*/
	mysql_stmt_close(login_procedure);
	return role;

err:
	mysql_stmt_close(login_procedure);
err2:
	return FAILED_LOGIN;
}

void login(MYSQL *conn) {
	role_t role;


	printf("Username: ");
	fflush(stdout);
	fgets(conf.username, DIM, stdin);
	conf.username[strlen(conf.username) - 1] = '\0';
	printf("\nPassword: ");
	fflush(stdout);
	insertPassword(conf.password);

	role = attempt_login(conn, conf.username, conf.password);

	/*A seconda del ruolo dell'utente che ha fatto il login, voglio far girare il mio applicativo
	come se fossi un moderatore o come se fossi un giocatore o in caso di login fallito uscire*/
	switch (role) {
	case MODERATORE:
		run_as_moderatore(conn);
		break;

	case GIOCATORE:
		run_as_giocatore(conn);
		break;

	case FAILED_LOGIN:
		fprintf(stderr, "Invalid credentials\n");
		exit(EXIT_FAILURE);
		break;

	default:
		fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
		abort();
	}

}

void registra_giocatore(MYSQL* conn) {
	MYSQL_STMT* prepared_stmt;
	MYSQL_BIND param[2];

	char username[46];
	char password[46];

	printf("Inserire username: ");
	fflush(stdout);
	fgets(username, DIM, stdin);
	username[strlen(username) - 1] = '\0';
	printf("\nInserire password: ");
	fflush(stdout);
	insertPassword(password);

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call aggiungi_giocatore(?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aggiungi_giocatore statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = username;
	param[0].buffer_length = strlen(username);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[1].buffer = password;
	param[1].buffer_length = strlen(password);



	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aggiungi_giocatore\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occurred while retrieving aggiungi_giocatore");
	}else
		printf("Giocatore registrato correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

int main(void) {
	char options[3] = {'1','2','3'};
	char op;

	if (!parse_config("users/login.json", &conf)) {
		fprintf(stderr, "Unable to load login configuration\n");
		exit(EXIT_FAILURE);
	}

	conn = mysql_init(NULL);
	if (conn == NULL) {
		fprintf(stderr, "mysql_init() failed (probably out of memory)\n");
		exit(EXIT_FAILURE);
	}

	if (mysql_real_connect(conn, conf.host, conf.db_username, conf.db_password, conf.database, conf.port, NULL, CLIENT_MULTI_STATEMENTS | CLIENT_MULTI_RESULTS) == NULL) {
		fprintf(stderr, "mysql_real_connect() failed\n");
		mysql_close(conn);
		exit(EXIT_FAILURE);
	}

	while (1) {
		system("cls");
		//printf("\033[2J\033[H");
		printf("*** Cosa desideri fare? ***\n\n");
		printf("1) Login\n");
		printf("2) Registrazione\n");
		printf("3) Uscire\n");

		op = multiChoice("Select an option", options, 3);

		switch (op) {
		case '1':
			login(conn);
			break;

		case '2':
			registra_giocatore(conn);
			break;

		case '3':
			return;

		default:
			fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
			abort();
		}
		_getch();
	}

	printf("Bye!\n");

	mysql_close(conn);
	return 0;
}