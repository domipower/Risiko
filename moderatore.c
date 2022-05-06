#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"

#define DIM 46

static void aggiungi_moderatore(MYSQL* conn) {
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
	if (!setup_prepared_stmt(&prepared_stmt, "call aggiungi_moderatore(?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aggiungi_moderatore statement\n", false);
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
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aggiungi_moderatore\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occurred while retrieving aggiungi_moderatore\n");
	}
	else
		printf("Nuovo moderatore registrato correttamente\n");

	mysql_stmt_close(prepared_stmt);
}


static void crea_stanzadigioco(MYSQL* conn) {
	MYSQL_STMT* prepared_stmt;
	MYSQL_BIND param[1];

	char nomestanza[16];

	printf("Inserire nome stanza di gioco: ");
	fflush(stdout);
	fgets(nomestanza, 16, stdin);
	nomestanza[strlen(nomestanza) - 1] = '\0';

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call crea_stanzadigioco(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize crea_stanzadigioco statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = nomestanza;
	param[0].buffer_length = strlen(nomestanza);



	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for crea_stanzadigioco\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occurred while retrieving crea_stanzadigioco\n");
	}
	else
		printf("Nuova stanza di gioco creata correttamente\n");

	mysql_stmt_close(prepared_stmt);
}



static void report(MYSQL* conn) {
	MYSQL_STMT* prepared_stmt;

	int status;
	char* title = "Numero di stanze di gioco con una partita attualmente in corso:";
	bool second_tb = false;
	bool third_tb = false;

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call report_moderatore()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize career report statement\n", false);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occurred while retrieving the career report.");
		goto out;
	}

	// We have multiple result sets here!
	do {
		if (third_tb == true) {
			title = "\n\nNumero di giocatori che hanno effettuato almeno una un'azione degli ultimi 15 minuti, che non sono in nessuna stanza di gioco:";
			second_tb = false;
			third_tb = false;
		}

		if (second_tb == true) {
		title = "\n\nStanze di gioco con una partita attualmente in corso e numero di giocatori in ciascuna di queste ultime:";
		second_tb = false;
		third_tb = true;
		}

		dump_result_set(conn, prepared_stmt, title);
		// more results? -1 = no, >0 = error, 0 = yes (keep looking)
		status = mysql_stmt_next_result(prepared_stmt);
		if (status > 0)
			finish_with_stmt_error(conn, prepared_stmt, "Unexpected condition", true);

		second_tb = true;

	} while (status == 0);
	
out:
	mysql_stmt_close(prepared_stmt);
}

void run_as_moderatore(MYSQL* conn)
{
	char options[4] = {'1','2','3','4'};
	char op;

	/*Faccio privilege escalation, cambiando il tipo di connessione che ho con il mio DBMS
	per girare non piu' come utente di tipo login ma come utente di tipo moderatore*/
	printf("Switching to moderatore role...\n");

	if (!parse_config("users/moderatore.json", &conf)) {
		fprintf(stderr, "Unable to load moderatore configuration\n");
		exit(EXIT_FAILURE);
	}

	/*Sulla stessa connessione conn che e' gia instaurata voglio modificare qualcosa, in particolare
	voglio modificare lo username, la password ed eventualmente anche lo schema che sto utilizzando*/
	if (mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}

	/*Ciclo infinito*/
	while (1) {
		/*Cancello quello che c'e' sullo schermo*/
		printf("\033[2J\033[H");
		printf("*** Cosa desideri fare? ***\n\n");
		printf("1) Aggiungere un nuovo moderatore\n");
		printf("2) Creare una nuova stanza di gioco\n");
		printf("3) Visualizzare report\n");
		printf("4) Uscire\n");

		/*recupero l'operazione che voglio andare a realizzare chiamando multiChoice
		definita in inout.c */
		op = multiChoice("Select an option", options, 4);

		/*Tramite uno switch case attivo la funzione corrispondente all'operazione
		che voglio andare a realizzare*/
		switch (op) {
		case '1':
			aggiungi_moderatore(conn);
			break;

		case '2':
			crea_stanzadigioco(conn);
			break;

		case '3':
			report(conn);
			break;

		case '4':
			return;

		default:
			fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
			abort();
		}

		_getch();
	}
}
