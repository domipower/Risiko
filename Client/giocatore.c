#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql.h>
#include <Windows.h>

#include "defines.h"

#define DIM 16


static void stato_di_gioco(MYSQL* conn) {
	MYSQL_STMT* prepared_stmt;
	MYSQL_BIND param[1];

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call stato_di_gioco(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize stato_di_gioco statement\n", false);
		goto err2;
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = conf.username;
	param[0].buffer_length = strlen(conf.username);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) { // Note _param
		print_stmt_error(prepared_stmt, "Could not bind parameters for stato_di_gioco");
		goto err;
	}

	// Run procedure 
	/*Inviamo i parametri al DBMS*/
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not execute stato_di_gioco procedure");
		goto err;
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\nStato di gioco della partita");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);

	return;

err:
	mysql_stmt_close(prepared_stmt);
err2:
	return;
}


static void posizionamento(MYSQL* conn) {
	MYSQL_STMT* prepared_stmt;
	MYSQL_BIND param[3];
	char nome_stato[26];
	char num_armate[16];
	int num_armate_int;

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call posiziona_armate(?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize posiziona_armate statement\n", false);
		goto err2;
	}

	printf("Nome stato in cui posizionare armate: ");
	fflush(stdout);
	fgets(nome_stato, 26, stdin);
	nome_stato[strlen(nome_stato) - 1] = '\0';

	printf("Numero armate da posizionare: ");
	fgets(num_armate, DIM, stdin);
	num_armate[strlen(num_armate) - 1] = '\0';
	// Convert values
	num_armate_int = atoi(num_armate);
	if (num_armate_int == 0) {
		printf("Inserisci un numero di armate valido\n");
		goto err2;
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = conf.username;
	param[0].buffer_length = strlen(conf.username);

	param[1].buffer_type = MYSQL_TYPE_LONG; // IN
	param[1].buffer = &num_armate_int;
	param[1].buffer_length = sizeof(num_armate_int);

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[2].buffer = nome_stato;
	param[2].buffer_length = strlen(nome_stato);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) { // Note _param
		print_stmt_error(prepared_stmt, "Could not bind parameters for posiziona_armate");
		goto err;
	}

	// Run procedure 
	/*Inviamo i parametri al DBMS*/
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not execute posiziona_armate procedure");
		goto err;
	}

	/*Chiudo lo statement*/
	mysql_stmt_close(prepared_stmt);
	printf("L'azione di posizionamento e' stata effettuata correttamente\n");
	return;

err:
	mysql_stmt_close(prepared_stmt);
err2:
	return;
}

static void spostamento(MYSQL* conn) {
	MYSQL_STMT* prepared_stmt;
	MYSQL_BIND param[4];
	char nome_stato_part[26];
	char nome_stato_dest[26];
	char num_armate[16];
	int num_armate_int;

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call sposta_armate(?,?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize sposta_armate statement\n", false);
		goto err2;
	}

	printf("Nome stato da cui prendere le armate da spostare: ");
	fflush(stdout);
	fgets(nome_stato_part, 26, stdin);
	nome_stato_part[strlen(nome_stato_part) - 1] = '\0';

	printf("Nome stato in cui spostare le armate: ");
	fflush(stdout);
	fgets(nome_stato_dest, 26, stdin);
	nome_stato_dest[strlen(nome_stato_dest) - 1] = '\0';

	printf("Numero armate da spostare: ");
	fgets(num_armate, DIM, stdin);
	num_armate[strlen(num_armate) - 1] = '\0';
	// Convert values
	num_armate_int = atoi(num_armate);
	if (num_armate_int == 0) {
		printf("Inserisci un numero di armate valido\n");
		goto err2;
	}


	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = conf.username;
	param[0].buffer_length = strlen(conf.username);

	param[1].buffer_type = MYSQL_TYPE_LONG; // IN
	param[1].buffer = &num_armate_int;
	param[1].buffer_length = sizeof(num_armate_int);

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[2].buffer = nome_stato_part;
	param[2].buffer_length = strlen(nome_stato_part);

	param[3].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[3].buffer = nome_stato_dest;
	param[3].buffer_length = strlen(nome_stato_dest);


	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) { // Note _param
		print_stmt_error(prepared_stmt, "Could not bind parameters for sposta_armate");
		goto err;
	}

	// Run procedure 
	/*Inviamo i parametri al DBMS*/
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not execute sposta_armate procedure");
		goto err;
	}

	/*Chiudo lo statement*/
	mysql_stmt_close(prepared_stmt);
	printf("L'azione di spostamento e' stata effettuata correttamente\n");
	return;

err:
	mysql_stmt_close(prepared_stmt);
err2:
	return;
}


static void attacco(MYSQL* conn) {
	MYSQL_STMT* prepared_stmt;
	MYSQL_BIND param[4];
	char nome_stato_att[26];
	char nome_stato_dif[26];
	char num_armate[16];
	int num_armate_int;

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call effettua_attacco(?,?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize effettua_attacco statement\n", false);
		goto err2;
	}

	printf("Nome stato attaccante: ");
	fflush(stdout);
	fgets(nome_stato_att, 26, stdin);
	nome_stato_att[strlen(nome_stato_att) - 1] = '\0';

	printf("Nome stato attaccato: ");
	fflush(stdout);
	fgets(nome_stato_dif, 26, stdin);
	nome_stato_dif[strlen(nome_stato_dif) - 1] = '\0';

	printf("Numero armate da schierare in attacco: ");
	fgets(num_armate, DIM, stdin);
	num_armate[strlen(num_armate) - 1] = '\0';
	// Convert values
	num_armate_int = atoi(num_armate);
	if (num_armate_int == 0) {
		printf("Inserisci un numero di armate valido\n");
		goto err2;
	}


	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = conf.username;
	param[0].buffer_length = strlen(conf.username);

	param[1].buffer_type = MYSQL_TYPE_LONG; // IN
	param[1].buffer = &num_armate_int;
	param[1].buffer_length = sizeof(num_armate_int);

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[2].buffer = nome_stato_att;
	param[2].buffer_length = strlen(nome_stato_att);

	param[3].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[3].buffer = nome_stato_dif;
	param[3].buffer_length = strlen(nome_stato_dif);
	

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) { // Note _param
		print_stmt_error(prepared_stmt, "Could not bind parameters for effettua_attacco");
		goto err;
	}

	// Run procedure 
	/*Inviamo i parametri al DBMS*/
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not execute effettua_attacco procedure");
		goto err;
	}

	/*Chiudo lo statement*/
	mysql_stmt_close(prepared_stmt);
	printf("L'azione di attacco e' stata effettuata correttamente\n");
	return;

err:
	mysql_stmt_close(prepared_stmt);
err2:
	return;
}

static void gioca_turno(MYSQL* conn) {
	char options[5] = { '1','2','3','4','5' };
	char op;

	/*Ciclo infinito*/
	while (1) {
		/*Cancello quello che c'e' sullo schermo*/
		printf("\033[2J\033[H");
		printf("*** Quale azione vuoi effettuare? ***\n\n");
		printf("1) Visualizzare lo stato di gioco\n");
		printf("2) Posizionare armate\n");
		printf("3) Spostare armate\n");
		printf("4) Attaccare uno stato\n");
		printf("5) Uscire\n");

		/*recupero l'operazione che voglio andare a realizzare chiamando multiChoice definita in inout.c */
		op = multiChoice("Select an option", options, 5);

		/*Tramite uno switch case attivo la funzione corrispondente all'operazione
		che voglio andare a realizzare*/
		switch (op) {
		case '1':
			stato_di_gioco(conn);
			break;

		case '2':
			posizionamento(conn);
			break;

		case '3':
			spostamento(conn);
			break;

		case '4':
			attacco(conn);
			break;

		case '5':
			return;

		default:
			fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
			abort();
		}
		_getch();
	}
}


static void crea_partita(MYSQL* conn) {
	MYSQL_STMT* prepared_stmt;
	MYSQL_BIND param[3];
	char nome_stanza[16];
	int idpartita;

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizza_stanze_libere()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize stanze_libere statement\n", false);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occurred while retrieving stanze_libere.");
	}
	
	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\nLista delle stanze di gioco libere");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);

	printf("Nome stanza: ");
	fflush(stdout);
	fgets(nome_stanza, DIM, stdin);
	nome_stanza[strlen(nome_stanza) - 1] = '\0';

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call crea_partita(?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize crea_partita statement\n", false);
		goto err2;
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = nome_stanza;
	param[0].buffer_length = strlen(nome_stanza);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[1].buffer = conf.username;
	param[1].buffer_length = strlen(conf.username);

	param[2].buffer_type = MYSQL_TYPE_LONG; // OUT
	param[2].buffer = &idpartita;
	param[2].buffer_length = sizeof(idpartita);


	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) { // Note _param
		print_stmt_error(prepared_stmt, "Could not bind parameters for crea_partita");
		goto err;
	}

	// Run procedure 
	/*Inviamo i parametri al DBMS*/
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not execute crea_partita procedure");
		goto err;
	}

	// Prepare output parameters
	/*Binding al contrario per ottenere dal DBMS il parametro out della procedura login*/
	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_LONG; // OUT
	param[0].buffer = &idpartita;
	param[0].buffer_length = sizeof(idpartita);

	if (mysql_stmt_bind_result(prepared_stmt, param)) {
		print_stmt_error(prepared_stmt, "Could not retrieve output parameter");
		goto err;
	}

	// Retrieve output parameter
	/*Estraggo il parametro out dal result set, che in questo caso e' una tabella 1x1*/
	if (mysql_stmt_fetch(prepared_stmt)) {
		print_stmt_error(prepared_stmt, "Could not buffer results");
		goto err;
	}

	/*Chiudo lo statement*/
	mysql_stmt_close(prepared_stmt);

	printf ("E' stata creata la partita con id: %i\n", idpartita);
	gioca_turno(conn);

err:
	mysql_stmt_close(prepared_stmt);
err2:
	return;
}


static void visualizza_storico_partite(MYSQL* conn) {
	MYSQL_STMT* prepared_stmt;
	MYSQL_BIND param[1];

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call storico_partite(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize storico_partite statement\n", false);
		goto err2;
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = conf.username;
	param[0].buffer_length = strlen(conf.username);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) { // Note _param
		print_stmt_error(prepared_stmt, "Could not bind parameters for storico_partite\n");
		goto err;
	}

	// Run procedure 
	/*Inviamo i parametri al DBMS*/
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not execute storico_partite procedure\n");
		goto err;
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "Storico partite giocate\n");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);

	return;

	err:
		mysql_stmt_close(prepared_stmt);
	err2:
		return;
}





static void partecipa_partita(MYSQL* conn) {
	MYSQL_STMT* prepared_stmt;
	MYSQL_BIND param[2];
	char partita[16];
	int partita_int;

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizza_partite_in_attesa()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize partite_in_attesa statement\n", false);
		goto err2;
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occurred while retrieving partite_in_attesa");
		goto err;
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\nLista partite in attesa");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);

	printf("Partita: ");
	fflush(stdout);
	fgets(partita, DIM, stdin);
	partita[strlen(partita) - 1] = '\0';
	// Convert values
	partita_int = atoi(partita);

	// Prepare stored procedure call
	if (!setup_prepared_stmt(&prepared_stmt, "call partecipa_partita(?, ?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize partecipa_partita statement\n", false);
		goto err2;
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = conf.username;
	param[0].buffer_length = strlen(conf.username);

	param[1].buffer_type = MYSQL_TYPE_LONG; // IN
	param[1].buffer = &partita_int;
	param[1].buffer_length = sizeof(partita_int);


	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) { // Note _param
		print_stmt_error(prepared_stmt, "Could not bind parameters for partecipa_partita");
		goto err;
	}

	// Run procedure 
	/*Inviamo i parametri al DBMS*/
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not execute partecipa_partita procedure");
		goto err;
	}

	mysql_stmt_close(prepared_stmt);

	printf("Giocatore entrato nella partita con id: %i\n", partita_int);
	gioca_turno(conn);

err:
	mysql_stmt_close(prepared_stmt);
err2:
	return;

}



void run_as_giocatore(MYSQL* conn)
{
	char options[4] = {'1','2','3','4' };
	char op;

	/*Faccio privilege escalation, cambiando il tipo di connessione che ho con il mio DBMS
	per girare non piu' come utente di tipo login ma come utente di tipo giocatore*/
	printf("Switching to giocatore role...\n");

	if (!parse_config("users/giocatore.json", &conf)) {
		fprintf(stderr, "Unable to load giocatore configuration\n");
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
		printf("1) Creare una nuova partita\n");
		printf("2) Partecipare a una partita\n");
		printf("3) Visualizzare storico partite\n");
		printf("4) Uscire\n");

		/*recupero l'operazione che voglio andare a realizzare chiamando multiChoice definita in inout.c */
		op = multiChoice("Select an option", options, 4);

		/*Tramite uno switch case attivo la funzione corrispondente all'operazione
		che voglio andare a realizzare*/
		switch (op) {
		case '1':
			crea_partita(conn);
			break;

		case '2':
			partecipa_partita(conn);
			break;

		case '3':
			visualizza_storico_partite(conn);
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