-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mydb` ;

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8mb4 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Utente`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Utente` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Utente` (
  `nomeutente` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `tipo` ENUM('giocatore', 'moderatore') NOT NULL,
  `armatedaposizionare` INT UNSIGNED NULL,
  PRIMARY KEY (`nomeutente`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Stanzadigioco`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Stanzadigioco` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Stanzadigioco` (
  `nomestanza` VARCHAR(15) NOT NULL,
  PRIMARY KEY (`nomestanza`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Partita`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Partita` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Partita` (
  `idpartita` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `statopartita` ENUM('inattesa', 'incorso', 'terminata') NOT NULL,
  `stanzadigioco` VARCHAR(15) NOT NULL,
  `iniziocountdown` DATETIME NULL,
  `vincitore` VARCHAR(45) NULL,
  PRIMARY KEY (`idpartita`),
  CONSTRAINT `fk_partita_Stanzadigioco1`
    FOREIGN KEY (`stanzadigioco`)
    REFERENCES `mydb`.`Stanzadigioco` (`nomestanza`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_partita_Stanzadigioco1_idx` ON `mydb`.`Partita` (`stanzadigioco` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Gioca`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Gioca` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Gioca` (
  `numturno` INT UNSIGNED NOT NULL,
  `giocatore` VARCHAR(45) NOT NULL,
  `partita` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`giocatore`, `partita`),
  CONSTRAINT `fk_gioca_Utente`
    FOREIGN KEY (`giocatore`)
    REFERENCES `mydb`.`Utente` (`nomeutente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Gioca_Partita1`
    FOREIGN KEY (`partita`)
    REFERENCES `mydb`.`Partita` (`idpartita`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Gioca_Partita1_idx` ON `mydb`.`Gioca` (`partita` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Turno`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Turno` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Turno` (
  `idturno` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tempoazione` DATETIME NULL,
  `tipoazione` ENUM('posizionamento', 'attacco', 'spostamento', 'nonsvolta') NULL,
  `partita` INT UNSIGNED NOT NULL,
  `inizioturno` DATETIME NOT NULL,
  `giocatore` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idturno`, `partita`, `giocatore`),
  CONSTRAINT `fk_Turno_partita1`
    FOREIGN KEY (`partita`)
    REFERENCES `mydb`.`Partita` (`idpartita`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Turno_Utente1`
    FOREIGN KEY (`giocatore`)
    REFERENCES `mydb`.`Utente` (`nomeutente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Turno_partita1_idx` ON `mydb`.`Turno` (`partita` ASC) VISIBLE;

CREATE INDEX `fk_Turno_Utente1_idx` ON `mydb`.`Turno` (`giocatore` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Stato`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Stato` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Stato` (
  `nomestato` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`nomestato`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Statotabellone`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Statotabellone` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Statotabellone` (
  `numarmate` INT UNSIGNED NOT NULL DEFAULT 3,
  `giocatore` VARCHAR(45) NOT NULL,
  `partita` INT UNSIGNED NOT NULL,
  `stato` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`giocatore`, `partita`, `stato`),
  CONSTRAINT `fk_Statotabellone_Utente1`
    FOREIGN KEY (`giocatore`)
    REFERENCES `mydb`.`Utente` (`nomeutente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Statotabellone_partita1`
    FOREIGN KEY (`partita`)
    REFERENCES `mydb`.`Partita` (`idpartita`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Statotabellone_Stato1`
    FOREIGN KEY (`stato`)
    REFERENCES `mydb`.`Stato` (`nomestato`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Statotabellone_partita1_idx` ON `mydb`.`Statotabellone` (`partita` ASC) VISIBLE;

CREATE INDEX `fk_Statotabellone_Stato1_idx` ON `mydb`.`Statotabellone` (`stato` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mydb`.`Confina`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Confina` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Confina` (
  `stato` VARCHAR(25) NOT NULL,
  `confinante` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`stato`, `confinante`),
  CONSTRAINT `fk_Confina_Stato1`
    FOREIGN KEY (`stato`)
    REFERENCES `mydb`.`Stato` (`nomestato`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Confina_Stato2`
    FOREIGN KEY (`confinante`)
    REFERENCES `mydb`.`Stato` (`nomestato`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Confina_Stato2_idx` ON `mydb`.`Confina` (`confinante` ASC) VISIBLE;

USE `mydb` ;

-- -----------------------------------------------------
-- procedure login
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`login`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `login` (in var_nomeutente VARCHAR(45), in var_password VARCHAR(45), out var_ruolo INT)
BEGIN
	declare var_ruolo_utente ENUM('giocatore', 'moderatore');
    select tipo from Utente 
		where nomeutente = var_nomeutente
        and password = md5(var_password)
        into var_ruolo_utente;
        
    -- enum corrispondente nel client
	if var_ruolo_utente = 'giocatore' then set var_ruolo = 1;
    elseif var_ruolo_utente = 'moderatore' then set var_ruolo = 2;
    else set var_ruolo = 3;
    end if;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure crea_stanzadigioco
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`crea_stanzadigioco`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `crea_stanzadigioco` (in var_nomestanza VARCHAR(15))
BEGIN
	insert into Stanzadigioco VALUES (var_nomestanza);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_giocatore
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`aggiungi_giocatore`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `aggiungi_giocatore` (in var_nomeutente VARCHAR(45), in var_password VARCHAR(45))
BEGIN
	insert into Utente (nomeutente, password, tipo) VALUES(var_nomeutente, md5(var_password), 'giocatore');
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure partecipa_partita
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`partecipa_partita`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `partecipa_partita` (in var_giocatore VARCHAR(45), in var_partita INT)
BEGIN
    declare var_partecipare INT;
    declare var_numturno INT;
    declare var_statopartita ENUM('inattesa', 'incorso', 'terminata');
    
	declare exit handler for sqlexception
    begin
		rollback;  -- rollback any changes made in the transaction
		resignal;  -- raise again the sql exception to the caller
    end;
    
	set transaction isolation level read committed;
	start transaction;
    
    -- controllo se il giocatore sta già partecipando a una partita
    select count(*) 
		from Gioca join Partita on Gioca.partita = Partita.idpartita
		where giocatore = var_giocatore and statopartita <> 'terminata'
        into var_partecipare;
        
    if var_partecipare > 0 then
        signal sqlstate '45000' set message_text = "Il giocatore sta gia' partecipando a un'altra partita";
    end if;
        
    -- controllo se var_partita è una partita in attesa (se in corso o terminata non è possibile partecipare)
    select statopartita from Partita 
		where idpartita = var_partita
        into var_statopartita;
	
    if var_statopartita <> 'inattesa' then
		signal sqlstate '45001' set message_text = "Non e' possibile partecipare a questa partita, perche' in corso o terminata";
	end if;
    
    -- azzero il numero di armatedaposizionare per il giocatore, che magari può aver giocato precedentemente 
    -- un'altra partita e avere ancora delle armate vecchie
    update Utente set armatedaposizionare = 0 where nomeutente = var_giocatore;
    
	-- salvo in var_numturno il numero assegnato all'ultimo giocatore entrato nella partita in esame e poi lo incremento di 1
    select count(giocatore) from Gioca
		where partita = var_partita 
        into var_numturno;
       
    set var_numturno = var_numturno +1;   
    insert into Gioca VALUES(var_numturno, var_giocatore, var_partita);
    
    -- quando entra il terzo giocatore viene avviato il countdown per far iniziare la partita dopo 2 minuti
    if var_numturno = 3 then
		update Partita set iniziocountdown = now() where idpartita = var_partita;
	end if;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure assegna_stati
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`assegna_stati`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `assegna_stati` (in var_partita INT)
BEGIN
	declare var_numturno INT;
    declare var INT;
    declare var_nomegiocatore VARCHAR(45);
    declare var_numgiocatori INT;
    declare var_nomestato VARCHAR(25);
    
    set var = 0;
    
	select count(giocatore)
		from Gioca
        where Gioca.partita = var_partita
		into var_numgiocatori;
	
    while var < 42 do
		select nomestato
			from Stato
            where nomestato not in (select stato from Statotabellone where partita = var_partita)
            order by rand() limit 1
            into var_nomestato; 
            
		-- numturno del giocatore a cui devo assegnare lo stato
        set var_numturno = (var % var_numgiocatori) + 1;
		select giocatore
			from Gioca
			where numturno = var_numturno and Gioca.partita = var_partita
            into var_nomegiocatore;
		insert into Statotabellone (giocatore, partita, stato) values (var_nomegiocatore, var_partita, var_nomestato);
		set var = var+1;
    end while;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure report_moderatore
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`report_moderatore`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `report_moderatore` ()
BEGIN
	set transaction read only;
	set transaction isolation level repeatable read;
	start transaction;
    
    select count(stanzadigioco) as numstanze
		from Stanzadigioco join Partita on Stanzadigioco.nomestanza = Partita.stanzadigioco
        where statopartita = 'incorso';
        
	select stanzadigioco, idpartita, count(giocatore) as numgiocatori 
		from Partita join Gioca on Partita.idpartita = Gioca.partita
		where Partita.statopartita = "incorso"
		group by idpartita;
        
	select count(distinct nomeutente) as giocatoriusciti
		from Partita join Gioca on Partita.idpartita = Gioca.partita
			join Utente on Gioca.giocatore = Utente.nomeutente
			join Turno on Utente.nomeutente = Turno.giocatore 
		where Partita.statopartita = "terminata" and Turno.tempoazione >= (now()-interval 15 minute);        
	
    commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storico_partite
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`storico_partite`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `storico_partite` (in var_giocatore VARCHAR(45))
BEGIN
	declare var_numpartite INT;
    
    declare exit handler for sqlexception
    begin
		rollback;  -- rollback any changes made in the transaction
		resignal;  -- raise again the sql exception to the caller
    end;
    
	set transaction isolation level read committed;
    start transaction;  
    
    select count(idpartita)
		from Gioca join Partita on Gioca.partita = Partita.idpartita
        where giocatore = var_giocatore and statopartita = 'terminata'
        into var_numpartite;
        
    if var_numpartite < 1 then
		signal sqlstate '45000' set message_text = "L'utente non ha partite terminate";
	end if;
		
	select idpartita, stanzadigioco, vincitore
		from Gioca join Partita on Gioca.partita = Partita.idpartita 
        where giocatore = var_giocatore and statopartita = 'terminata';
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure stato_di_gioco
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`stato_di_gioco`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `stato_di_gioco` (in var_giocatore VARCHAR(45))
BEGIN
    declare var_partita INT;
    declare var_statopartita ENUM('inattesa', 'incorso', 'terminata');
    declare var_numturno INT;
    declare var_numturnoprecedente INT;
    declare var_numgiocatori INT;
    
    declare var_statiposseduti INT;
    
    declare exit handler for sqlexception
    begin
       rollback;  -- rollback any changes made in the transaction
		resignal;  -- raise again the sql exception to the caller
    end;
    
    set transaction read only;
	set transaction isolation level read committed;
	start transaction;  
    
    select restituisci_partita(var_giocatore) into var_partita;
    
	-- controllo se la partita e' stata avviata o e' ancora in attesa o è gia' terminata
	select statopartita
		from Partita
		where idpartita = var_partita
		into var_statopartita;

	if var_statopartita = 'inattesa' then
		signal sqlstate '45000' set message_text = "Attendere che la partita inizi";
	end if;

	if var_statopartita = 'terminata' then
		signal sqlstate '45001' set message_text = "La partita e' terminata";
	end if;

	-- controllo che il giocatore non abbia perso 
	select count(*)
		from Statotabellone
		where giocatore = var_giocatore and partita = var_partita
		into var_statiposseduti;
    
	if var_statiposseduti = 0 then
		signal sqlstate '45002' set message_text = "Hai perso la partita!";
	end if;

	-- controllo che sia il turno del giocatore che vuole visualizzare lo stato di gioco
    select numturno
		from Gioca
        where Gioca.giocatore = var_giocatore and Gioca.partita = var_partita
        into var_numturno;
	
    select count(*)
		from Gioca join Partita on Gioca.partita = Partita.idpartita
		where idpartita = var_partita
        into var_numgiocatori;
        
    select numturno
		from Turno join Utente on Turno.giocatore = Utente.nomeutente
			join Gioca on Utente.nomeutente = Gioca.giocatore
		where Turno.partita = var_partita 
        order by idturno desc limit 1
		into var_numturnoprecedente;
	
    if (var_numturnoprecedente % var_numgiocatori) <> var_numturno then
		signal sqlstate '45000' set message_text = "Non e' il tuo turno";
	end if;

	select s1.giocatore, s1.numarmate, nomestato, confinante, s2.giocatore, s2.numarmate
		from Statotabellone as s1 join Stato on s1.stato = Stato.nomestato
			join Confina on Stato.nomestato = Confina.stato 
			join Statotabellone as s2 on Confina.confinante = s2.stato
		where s1.partita = var_partita and s2.partita = var_partita;
    
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure posiziona_armate
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`posiziona_armate`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `posiziona_armate` (in var_giocatore VARCHAR(45), in var_numarmate INT, in var_stato VARCHAR(25))
BEGIN
	declare var_partita INT;
    declare var_statopartita ENUM('inattesa', 'incorso', 'terminata');
    declare var_possiede INT;
    declare var_idturno INT;
    declare var_armatedaposiz INT;
    declare var_tipoazione ENUM('posizionamento', 'attacco', 'spostamento', 'nonsvolta');
    declare var_statiposseduti INT;
    
    declare exit handler for sqlexception
    begin
       rollback;  -- rollback any changes made in the transaction
       resignal;  -- raise again the sql exception to the caller
    end;
    
    select restituisci_partita(var_giocatore) into var_partita;
    
	-- controllo se la partita e' stata avviata o e' ancora in attesa o e' gia' terminata
	select statopartita
		from Partita
		where idpartita = var_partita
		into var_statopartita;

	if var_statopartita = 'inattesa' then
		signal sqlstate '45000' set message_text = "Attendere che la partita inizi";
	end if;

	if var_statopartita = 'terminata' then
		signal sqlstate '45001' set message_text = "La partita e' terminata";
	end if;

	-- controllo che il giocatore non abbia perso
	select count(*)
		from Statotabellone
		where giocatore = var_giocatore and partita = var_partita
		into var_statiposseduti;
    
	if var_statiposseduti = 0 then
		signal sqlstate '45002' set message_text = "Hai perso la partita!";
	end if;

	-- controllo che non sia già stata effettuata un'azione nello stesso turno
	select idturno
		from Turno
		where partita = var_partita and Turno.giocatore = var_giocatore 
        order by idturno desc limit 1
        into var_idturno;
        
    select tipoazione
		from Turno
        where idturno = var_idturno
        into var_tipoazione;
        
    if var_tipoazione is not null then
		signal sqlstate '45003' set message_text = "Hai gia' giocato il turno";
	end if;

	-- controllo se lo stato appartiene al giocatore 
	select count(*) 
		from Statotabellone 
        where Statotabellone.giocatore = var_giocatore and partita = var_partita and stato = upper(var_stato)
		into var_possiede;
    
    if var_possiede <> 1 then
		signal sqlstate '45004' set message_text = "Lo stato non appartiene al giocatore";
	end if;
    
	-- controllo se il giocatore effettivamente possiede il numarmate che vuole posizionare
	select armatedaposizionare
		from Utente join Gioca on Utente.nomeutente = Gioca.giocatore
		where nomeutente = var_giocatore and partita = var_partita
		into var_armatedaposiz;
    
	if var_numarmate > var_armatedaposiz then
		signal sqlstate '45005' set message_text = "Il giocatore non possiede il numarmate che vuole posizionare";
	end if;
        
	update Statotabellone set numarmate = (numarmate + var_numarmate) 
			where Statotabellone.giocatore = var_giocatore and partita = var_partita and stato = upper(var_stato);
    
    update Utente set armatedaposizionare = armatedaposizionare - var_numarmate
		where nomeutente = var_giocatore;
	
    update Turno set tipoazione = 'posizionamento', tempoazione = now()
	 	where idturno = var_idturno and tipoazione is null;
	
    call turno_successivo(var_giocatore, var_partita);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure assegna_nuove_armate
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`assegna_nuove_armate`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `assegna_nuove_armate` (in var_giocatore VARCHAR(45))
BEGIN
	declare var_partita INT;
    declare var_numstati INT;
    declare var_nuovearmate INT;
    
    set transaction isolation level read committed;
    start transaction;
    
	select restituisci_partita_incorso(var_giocatore) into var_partita;
    
    -- calcolo il numero di nuove armate da assegnare
    select count(stato)
		from Statotabellone
        where Statotabellone.giocatore = var_giocatore and Statotabellone.partita = var_partita
        into var_numstati;
	
	set var_nuovearmate = var_numstati/3;
	set var_nuovearmate = ceiling(var_nuovearmate);
	
	update Utente set armatedaposizionare = (armatedaposizionare + var_nuovearmate) 
			where nomeutente = var_giocatore;
		
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure gioca_turno
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`gioca_turno`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `gioca_turno` (in var_giocatore VARCHAR(45))
BEGIN
	declare var_partita INT;
    
	select restituisci_partita_incorso(var_giocatore) into var_partita;
   
	insert into Turno (partita, giocatore, inizioturno) 
		values(var_partita, var_giocatore, now());
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_moderatore
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`aggiungi_moderatore`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `aggiungi_moderatore` (in var_nomeutente VARCHAR(45), in var_password VARCHAR(45))
BEGIN
	insert into Utente (nomeutente, password, tipo) VALUES(var_nomeutente, md5(var_password), 'moderatore');
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure effettua_attacco
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`effettua_attacco`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `effettua_attacco` (in var_attaccante VARCHAR(45), in var_numarmateatt INT, 
in var_statoatt VARCHAR(25), in var_statodif VARCHAR(25))
BEGIN
	declare var_partita INT;
	declare var_possiede INT;
    declare var_confinanti INT;
	declare var_armateposseduteatt INT;
    declare var_difensore VARCHAR(45);
    declare var_armatepossedutedif INT;
    declare var_numarmatedif INT;
    declare var_numdadiatt INT;
    declare var_numdadidif INT;
    declare var_idturno INT;
    
	declare dado1_att INT;
	declare dado2_att INT default null;
	declare dado3_att INT default null;
    declare dado1_dif INT;
	declare dado2_dif INT default null;
	declare dado3_dif INT default null;
    
	declare armate_perse_att INT default 0;
    declare armate_perse_dif INT default 0;
    
	declare var_statopartita ENUM('inattesa', 'incorso', 'terminata');
    declare var_tipoazione ENUM('posizionamento', 'attacco', 'spostamento', 'nonsvolta');
	declare var_statiposseduti INT;
    
	declare exit handler for sqlexception
	begin
		rollback;  -- rollback any changes made in the transaction
		resignal;  -- raise again the sql exception to the caller
	end;
    
    select restituisci_partita(var_attaccante) into var_partita;

	-- controllo se la partita e' stata avviata o e' ancora in attesa o e' gia' terminata
	select statopartita
		from Partita
		where idpartita = var_partita
		into var_statopartita;

	if var_statopartita = 'inattesa' then
		signal sqlstate '45000' set message_text = "Attendere che la partita inizi";
	end if;

	if var_statopartita = 'terminata' then
		signal sqlstate '45001' set message_text = "La partita e' terminata";
	end if;

	-- controllo che il giocatore non abbia perso
	select count(*)
		from Statotabellone
		where giocatore = var_attaccante and partita = var_partita
		into var_statiposseduti;
    
	if var_statiposseduti = 0 then
		signal sqlstate '45002' set message_text = "Hai perso la partita!";
	end if;

	-- controllo che non sia già stata effettuata un'azione nello stesso turno
    select idturno
		from Turno
		where partita = var_partita and Turno.giocatore = var_attaccante
        order by idturno desc limit 1
        into var_idturno;
        
    select tipoazione
		from Turno
        where idturno = var_idturno
        into var_tipoazione;
        
    if var_tipoazione is not null then
		signal sqlstate '45003' set message_text = "Hai gia' giocato il turno";
	end if;

	-- controllo se lo statoatt appartiene all'attaccante 
	select count(*) 
		from Statotabellone 
        where giocatore = var_attaccante and partita = var_partita and stato = upper(var_statoatt)
		into var_possiede;
    
    if var_possiede <> 1 then
		signal sqlstate '45004' set message_text = "Lo statoatt non appartiene all'attaccante";
	end if;
    
	-- controllo se statoatt e statodif confinano e se appartengono a giocatori diversi
	select count(*)
		from Confina 
        where stato = upper(var_statoatt) and confinante = upper(var_statodif)
        into var_confinanti;
        
	if var_confinanti <> 1 then
		signal sqlstate '45005' set message_text = "Stato attaccante e stato attaccato non confinano.";
	end if;
        
	select count(*) 
		from Statotabellone 
        where giocatore = var_attaccante and partita = var_partita and stato = upper(var_statodif)
		into var_possiede;
    
    if var_possiede = 1 then
		signal sqlstate '45006' set message_text = "Lo stato attaccato appartiene già all'attaccante";
	end if;
    
    -- controllo che l'attaccante possieda il numero di armate che vuole schierare 
    -- e che questo numero sia al massimo pari a 4 (cioè 3 dadi) 
    -- e almeno pari a 2 (cioè un dado)
    
    if var_numarmateatt > 4 then
		signal sqlstate '45007' set message_text = "Non e' possibile schierare piu' di 4 armate";	
	end if;
	if var_numarmateatt < 2 then
		signal sqlstate '45008' set message_text = "Non e' possibile schierare meno di 2 armate";	
	end if;
        
    select numarmate
		from Statotabellone
        where stato = upper(var_statoatt) and giocatore = var_attaccante and partita = var_partita
        into var_armateposseduteatt;
	
    if var_numarmateatt > var_armateposseduteatt then
		signal sqlstate '45009' set message_text = "L'attaccante non possiede il numero di armate che ha chiesto di schierare";
	end if;
    
    -- conoscere il difensore
    select giocatore
		from Statotabellone
        where stato = upper(var_statodif) and partita = var_partita
        into var_difensore;
    
    -- controllo le armate possedute dal difensore e, se ne ha di piu' rispetto al numarmateatt 
    -- ne prendo solo in numero pari ad numarmateatt, altrimenti se ne ha di meno le prendo tutte
    select numarmate
		from Statotabellone
        where stato = upper(var_statodif) and Statotabellone.giocatore = var_difensore and partita = var_partita
        into var_armatepossedutedif;
        
	if var_armatepossedutedif > var_numarmateatt then
		set var_numarmatedif = var_numarmateatt;
	else 
		set var_numarmatedif = var_armatepossedutedif;
	end if;
     
    -- calcolo il numero di dadi da lanciare 
	set var_numdadiatt = var_numarmateatt - 1;
    set var_numdadidif = var_numarmatedif - 1;
    
	-- lancio dadi
	if var_numdadiatt = 3 then
		set dado1_att = ceiling(rand()*6);
		set dado2_att = ceiling(rand()*6);
		set dado3_att = ceiling(rand()*6);
	
    elseif var_numdadiatt = 2 then
		set dado1_att = ceiling(rand()*6);
		set dado2_att = ceiling(rand()*6);
        
	elseif var_numdadiatt = 1 then
		set dado1_att = ceiling(rand()*6);
	end if;   
    
	if var_numdadidif = 3 then
		set dado1_dif = ceiling(rand()*6);
		set dado2_dif = ceiling(rand()*6);
		set dado3_dif = ceiling(rand()*6);
	
    elseif var_numdadidif = 2 then
		set dado1_dif = ceiling(rand()*6);
		set dado2_dif = ceiling(rand()*6);
        
	elseif var_numdadidif = 1 then
		set dado1_dif = ceiling(rand()*6);
	end if;    
  
    -- controllo vittoria lancio dadi
    call controlla_vittoria_lancio_dadi(dado1_att, dado2_att, dado3_att, dado1_dif, dado2_dif, dado3_dif, armate_perse_att, armate_perse_dif);
	
    if (var_armateposseduteatt - armate_perse_att > 0 and armate_perse_att <> 0) then
		update Statotabellone set numarmate = (numarmate - armate_perse_att) 
			where giocatore = var_attaccante and partita = var_partita and stato = upper(var_statoatt);
    elseif (var_armateposseduteatt - armate_perse_att = 0) then 
		update Statotabellone set Statotabellone.giocatore = var_difensore, numarmate = var_numarmatedif - armate_perse_dif
			where giocatore = var_attaccante and partita = var_partita and stato = upper(var_statoatt);
    end if;
    
	if (var_armatepossedutedif - armate_perse_dif > 0 and armate_perse_dif <> 0) then
		update Statotabellone set numarmate = (numarmate - armate_perse_dif) 
			where Statotabellone.giocatore = var_difensore and partita = var_partita and stato = upper(var_statodif);
	elseif (var_armatepossedutedif - armate_perse_dif = 0) then
		update Statotabellone set giocatore = var_attaccante, numarmate = var_numarmateatt - armate_perse_att
			where Statotabellone.giocatore = var_difensore and partita = var_partita and stato = upper(var_statodif);
    end if;
        
	update Turno set tipoazione = 'attacco', tempoazione = now()
	 	where idturno = var_idturno and Turno.giocatore = var_attaccante 
        and partita = var_partita and tempoazione is null;
    
    -- se gli stati appartengono tutti allo stesso giocatore (attaccante o difensore), la partita termina
    select count(*)
		from Statotabellone
		where giocatore = var_attaccante
		into var_statiposseduti;
    
	if var_statiposseduti = 42 then
        update Partita set vincitore = var_attaccante, statopartita = 'terminata'
			where idpartita = var_partita;
		signal sqlstate '45000' set message_text = "L'attaccante ha vinto la partita!";
    end if;
    
    select count(*)
		from Statotabellone
		where giocatore = var_difensore
		into var_statiposseduti;
    
    if var_statiposseduti = 42 then
        update Partita set vincitore = var_difensore, statopartita = 'terminata'
			where idpartita = var_partita;
		signal sqlstate '45001' set message_text = "Il difensore ha vinto la partita!";
    end if;
    
    call turno_successivo(var_attaccante, var_partita);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure sposta_armate
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`sposta_armate`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `sposta_armate` (in var_giocatore VARCHAR(45), in var_numarmate INT, in var_statopart VARCHAR(25), in var_statodest VARCHAR(25))
BEGIN
	declare var_possiede INT;
    declare var_confinanti INT;
    declare var_partita INT;
    declare var_armatetot INT;
    declare var_idturno INT;
	declare var_statopartita ENUM('inattesa', 'incorso', 'terminata');
    declare var_tipoazione ENUM('posizionamento', 'attacco', 'spostamento', 'nonsvolta');
    declare var_statiposseduti INT;
    
    declare exit handler for sqlexception
    begin
       rollback;  -- rollback any changes made in the transaction
       resignal;  -- raise again the sql exception to the caller
    end;
    
    select restituisci_partita(var_giocatore) into var_partita;
    
	-- controllo se la partita e' stata avviata o e' ancora in attesa o e' gia' terminata
	select statopartita
		from Partita
		where idpartita = var_partita
		into var_statopartita;

	if var_statopartita = 'inattesa' then
		signal sqlstate '45000' set message_text = "Attendere che la partita inizi";
	end if;

	if var_statopartita = 'terminata' then
		signal sqlstate '45001' set message_text = "La partita e' terminata";
	end if;

	-- controllo che il giocatore non abbia perso
	select count(*)
		from Statotabellone
		where giocatore = var_giocatore and partita = var_partita
		into var_statiposseduti;
    
	if var_statiposseduti = 0 then
		signal sqlstate '45002' set message_text = "Hai perso la partita!";
	end if;

	-- controllo che non sia già stata effettuata un'azione nello stesso turno
	select idturno
		from Turno
		where partita = var_partita and Turno.giocatore = var_giocatore 
        order by idturno desc limit 1
        into var_idturno;
        
    select tipoazione
		from Turno
        where idturno = var_idturno
        into var_tipoazione;
        
    if var_tipoazione is not null then
		signal sqlstate '45003' set message_text = "Hai gia' giocato il turno";
	end if;

	-- controllo se lo statopart e lo statodest appartengono al giocatore 
	select count(*) 
		from Statotabellone 
        where Statotabellone.giocatore = var_giocatore and Statotabellone.partita = var_partita and Statotabellone.stato = upper(var_statopart)
		into var_possiede;
    
    if var_possiede <> 1 then
		signal sqlstate '45004' set message_text = "Lo stato di partenza non appartiene al giocatore";
	end if;
    
    select count(*) 
		from Statotabellone 
        where Statotabellone.giocatore = var_giocatore and Statotabellone.partita = var_partita and Statotabellone.stato = upper(var_statodest)
		into var_possiede;
    
    if var_possiede <> 1 then
		signal sqlstate '45005' set message_text = "Lo stato di destinazione non appartiene al giocatore";
	end if;
    
    -- controllo che statopart e statodest siano confinanti
    select count(*)
		from Confina 
        where Confina.stato = upper(var_statopart) and confinante = upper(var_statodest)
        into var_confinanti;
        
	if var_confinanti <> 1 then
		signal sqlstate '45006' set message_text = "Stato di partenza e stato di destinazione non confinano.";
	end if;
    
    -- controllo che sullo statopart rimanga almeno un'armata
    
    select numarmate
		from Statotabellone
		where stato = upper(var_statopart) and Statotabellone.partita = var_partita 
        into var_armatetot;
        
	if var_armatetot - var_numarmate < 1 then
		signal sqlstate '45007' set message_text = "Sullo stato di partenza deve rimanere almeno un'armata";
	end if;
	
	update Statotabellone set numarmate = (numarmate + var_numarmate) 
			where Statotabellone.giocatore = var_giocatore and partita = var_partita and stato=var_statodest;
	
    update Statotabellone set numarmate = (numarmate - var_numarmate) 
			where Statotabellone.giocatore = var_giocatore and partita = var_partita and stato = upper(var_statopart);
        
	update Turno set tipoazione = 'spostamento', tempoazione = now()
	 	where idturno = var_idturno and tempoazione is null;
        
	call turno_successivo(var_giocatore, var_partita);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure controlla_vittoria_lancio_dadi
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`controlla_vittoria_lancio_dadi`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `controlla_vittoria_lancio_dadi` (in dado1_att INT, in dado2_att INT, in dado3_att INT, in dado1_dif INT, in dado2_dif INT, in dado3_dif INT, out armate_perse_att INT, out armate_perse_dif INT)
BEGIN
	-- Variabili che rappresentano il dado più alto, quello medio e quello più basso rispettivamente dell'attaccante e del difensore
	declare max_dado_att INT;											
	declare med_dado_att INT;
	declare min_dado_att INT;
	declare max_dado_dif INT;
	declare med_dado_dif INT;
	declare min_dado_dif INT;
    
    set transaction isolation level read uncommitted;
    start transaction;
    
    -- In base alla presenza o meno dei valori dei dadi, riordino i loro valori in modo che siano nelle variabili giuste
	-- se c'è un solo dado diverso da null
	if (dado2_att is null) and (dado3_att is null) then
		set max_dado_att = dado1_att;
    -- se ci sono due dadi diversi da null
	elseif dado3_att is null then				
		if (dado1_att >= dado2_att) then
			set max_dado_att = dado1_att;
			set med_dado_att = dado2_att;
		else
			set max_dado_att = dado2_att;
			set med_dado_att = dado1_att;
		end if;
    -- Tutti e tre i dadi non sono null    
	else 
		if((dado1_att >= dado2_att) and (dado1_att >= dado3_att)) then
			set max_dado_att = dado1_att;
			if(dado2_att > dado3_att) then
				set med_dado_att = dado2_att;
				set min_dado_att = dado3_att;
			else
				set med_dado_att = dado3_att;
				set min_dado_att = dado2_att;
			end if;
		elseif (dado2_att >= dado1_att) and (dado2_att >= dado3_att) then
			set max_dado_att = dado2_att;
			if(dado1_att > dado3_att) then
				set med_dado_att = dado1_att;
				set min_dado_att = dado3_att;
			else
				set med_dado_att = dado3_att;
				set min_dado_att = dado1_att;
			end if;
		else
			set max_dado_att = dado3_att;
			if(dado1_att > dado2_att) then
				set med_dado_att = dado1_att;
				set min_dado_att = dado2_att;
			else
				set med_dado_att = dado2_att;
				set min_dado_att = dado1_att;
			end if;
		end if;
	end if;
    
	-- ripeto la stessa cosa per i dadi del difensore
	-- se c'è un solo dado diverso da null
	if (dado2_dif is null) and (dado3_dif is null) then
		set max_dado_dif = dado1_dif;
    -- se ci sono due dadi diversi da null
	elseif dado3_dif is null then				
		if (dado1_dif >= dado2_dif) then
			set max_dado_dif = dado1_dif;
			set med_dado_dif = dado2_dif;
		else
			set max_dado_dif = dado2_dif;
			set med_dado_dif = dado1_dif;
		end if;
    -- Tutti e tre i dadi non sono null    
	else 
		if(dado1_dif >= dado2_dif) and (dado1_dif >= dado3_dif) then
			set max_dado_dif = dado1_dif;
			if(dado2_dif > dado3_dif) then
				set med_dado_dif = dado2_dif;
				set min_dado_dif = dado3_dif;
			else
				set med_dado_dif = dado3_dif;
				set min_dado_dif = dado2_dif;
			end if;
		elseif(dado2_dif >= dado1_dif) and (dado2_dif >= dado3_dif) then
			set max_dado_dif = dado2_dif;
			if(dado1_dif > dado3_dif) then
				set med_dado_dif = dado1_dif;
				set min_dado_dif = dado3_dif;
			else
				set med_dado_dif = dado3_dif;
				set min_dado_dif = dado1_dif;
			end if;
		else
			set max_dado_dif = dado3_dif;
			if(dado1_dif > dado2_dif) then
				set med_dado_dif = dado1_dif;
				set min_dado_dif = dado2_dif;
			else
				set med_dado_dif = dado2_dif;
				set min_dado_dif = dado1_dif;
			end if;
		end if;
	end if;
  
	-- Controllo dei valori MAX MED e MIN; il valore 1 indica che si è persa un'armata    
  
	if(max_dado_dif >= max_dado_att) then
		set armate_perse_att = 1; -- perde un'armata l'attaccante
		set armate_perse_dif = 0;
	else
		set armate_perse_dif = 1; -- perde un'armata il difensore
		set armate_perse_att = 0;
	end if;
	if((med_dado_att  is not null) and (med_dado_dif is not null)) then
		if(med_dado_dif >= med_dado_att) then
			set armate_perse_att = armate_perse_att + 1; -- perde un'armata l'attaccante
		else
			set armate_perse_dif = armate_perse_dif + 1; -- perde un'armata il difensore
		end if;
		if((min_dado_att is not null) and (min_dado_dif is not null)) then
			if(min_dado_dif >= min_dado_att) then
				set armate_perse_att = armate_perse_att + 1; -- perde un'armata l'attaccante 
			else
				set armate_perse_dif = armate_perse_dif + 1; -- perde un'armata il difensore
			end if;
		end if;
	end if;
 commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_stanze_libere
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`visualizza_stanze_libere`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `visualizza_stanze_libere` ()
BEGIN
	set transaction read only;
	set transaction isolation level read committed;
	start transaction;
	select nomestanza 
		from Stanzadigioco
        where nomestanza not in (select nomestanza
		from Stanzadigioco join Partita on Stanzadigioco.nomestanza = Partita.stanzadigioco
        where statopartita = 'incorso' or statopartita = 'inattesa');
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_partite_in_attesa
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`visualizza_partite_in_attesa`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `visualizza_partite_in_attesa` ()
BEGIN   
	set transaction read only;
	set transaction isolation level read committed;
	start transaction;
	select idpartita, stanzadigioco,  count(giocatore) as numgiocatori 
	   from Partita join Gioca on Partita.idpartita = Gioca.partita
       where statopartita = 'inattesa'
       group by idpartita;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure crea_partita
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`crea_partita`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `crea_partita` (in var_stanzadigioco VARCHAR(15), in var_giocatore VARCHAR(45), out var_idpartita INT)
BEGIN
	declare var_numpartite INT;
    
	declare exit handler for sqlexception
	begin
		rollback;  -- rollback any changes made in the transaction
		resignal;  -- raise again the sql exception to the caller
    end;
    
    set transaction isolation level read committed;
    start transaction;
    
	-- controllo che nella stessa stanza non ci siano altre partite inattesa o incorso
    select count(*)
		from Partita
        where stanzadigioco = var_stanzadigioco and (statopartita = 'incorso' or statopartita = 'inattesa')
        into var_numpartite;
        
	if var_numpartite <> 0 then
		signal sqlstate '45000' set message_text = "In questa stanza esiste gia' una partita inattesa o incorso";
	end if;
    
	insert into Partita (statopartita, stanzadigioco) values ('inattesa', var_stanzadigioco);

	select idpartita 
		from Partita 
        where statopartita = 'inattesa' and stanzadigioco = var_stanzadigioco
        into var_idpartita;
     
	insert into Gioca (giocatore, partita, numturno) values (var_giocatore, var_idpartita, 1);
	update Utente set armatedaposizionare = 0 where nomeutente = var_giocatore;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure turno_successivo
-- -----------------------------------------------------

USE `mydb`;
DROP procedure IF EXISTS `mydb`.`turno_successivo`;

DELIMITER $$
USE `mydb`$$
CREATE PROCEDURE `turno_successivo` (in var_giocatore VARCHAR(45), in var_partita INT)
BEGIN	
	declare var_numprossimoturno INT;
    declare var_prossimogiocatore VARCHAR(45);
    declare var_numgiocatori INT;
    declare var_numturno INT;
    declare var_tipoazione ENUM('spostamento', 'attacco', 'posizionamento', 'nonsvolta');
    
	select count(*)
		from Gioca join Partita on Gioca.partita = Partita.idpartita
		where idpartita = var_partita
        into var_numgiocatori;
		
	select numturno
		from Gioca
		where Gioca.giocatore = var_giocatore and Gioca.partita = var_partita
		into var_numturno;
            
	set var_numprossimoturno = (var_numturno % var_numgiocatori) + 1;
        
	select giocatore
		from Gioca
		where numturno = var_numprossimoturno and partita = var_partita
        into var_prossimogiocatore;
	
    select tipoazione
		from Turno
        where giocatore = var_giocatore and partita = var_partita
        order by idturno desc limit 1
        into var_tipoazione;
    
    if var_tipoazione <> 'nonsvolta' then
		call assegna_nuove_armate(var_giocatore);
	end if;
    
	call gioca_turno(var_prossimogiocatore);
END$$

DELIMITER ;
USE `mydb`;

DELIMITER $$

USE `mydb`$$
DROP TRIGGER IF EXISTS `mydb`.`Partita_AFTER_UPDATE` $$
USE `mydb`$$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`Partita_AFTER_UPDATE` AFTER UPDATE ON `Partita` FOR EACH ROW
BEGIN
	declare var_primogiocatore VARCHAR(45);

    if new.statopartita = 'incorso' then
		call assegna_stati(old.idpartita);
    
    select giocatore
		from Gioca
        where Gioca.partita = old.idpartita and numturno = 1
        into var_primogiocatore;
     
	call gioca_turno(var_primogiocatore);
    end if;
END$$


USE `mydb`$$
DROP TRIGGER IF EXISTS `mydb`.`Gioca_BEFORE_INSERT` $$
USE `mydb`$$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`Gioca_BEFORE_INSERT` BEFORE INSERT ON `Gioca` FOR EACH ROW
BEGIN
    if(new.numturno>6 or new.numturno<1) then
        signal sqlstate '45000' set message_text="E' stato raggiunto il numero massimo di giocatori per questa partita.";
    end if;
END$$


USE `mydb`$$
DROP TRIGGER IF EXISTS `mydb`.`Turno_BEFORE_INSERT` $$
USE `mydb`$$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`Turno_BEFORE_INSERT` BEFORE INSERT ON `Turno` FOR EACH ROW
BEGIN
	declare var_numturno INT;
    declare var_numturnoprecedente INT;
    declare var_partita INT;
    declare var_numgiocatori INT;
    
    set var_numturnoprecedente = 0;
      
	select restituisci_partita_incorso(new.giocatore) into var_partita;
      
    select numturno
		from Gioca
        where Gioca.giocatore = new.giocatore and Gioca.partita = var_partita
        into var_numturno;
	
    select count(*)
		from Gioca join Partita on Gioca.partita = Partita.idpartita
		where idpartita = var_partita
        into var_numgiocatori;
        
    select numturno
		from Turno join Utente on Turno.giocatore = Utente.nomeutente
			join Gioca on Utente.nomeutente = Gioca.giocatore
		where Turno.partita = var_partita 
        order by idturno desc limit 1
		into var_numturnoprecedente;
    
    if (var_numturnoprecedente % var_numgiocatori) + 1 <> var_numturno then
		signal sqlstate '45000' set message_text = "Non e' il tuo turno.";
	end if;
END$$


USE `mydb`$$
DROP TRIGGER IF EXISTS `mydb`.`Turno_BEFORE_UPDATE` $$
USE `mydb`$$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`Turno_BEFORE_UPDATE` BEFORE UPDATE ON `Turno` FOR EACH ROW
BEGIN
	if(new.tempoazione < old.inizioturno) then
        signal sqlstate '45000' set message_text="Il tempo di inizio dell'azione non puo' essere più piccolo del tempo di inizio del turno.";
    end if;
END$$


DELIMITER ;
SET SQL_MODE = '';
DROP USER IF EXISTS giocatore;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'giocatore' IDENTIFIED BY 'giocatore';

GRANT EXECUTE ON procedure `mydb`.`partecipa_partita` TO 'giocatore';
GRANT EXECUTE ON procedure `mydb`.`storico_partite` TO 'giocatore';
GRANT EXECUTE ON procedure `mydb`.`posiziona_armate` TO 'giocatore';
GRANT EXECUTE ON procedure `mydb`.`sposta_armate` TO 'giocatore';
GRANT EXECUTE ON procedure `mydb`.`effettua_attacco` TO 'giocatore';
GRANT EXECUTE ON procedure `mydb`.`visualizza_stanze_libere` TO 'giocatore';
GRANT EXECUTE ON procedure `mydb`.`visualizza_partite_in_attesa` TO 'giocatore';
GRANT EXECUTE ON procedure `mydb`.`crea_partita` TO 'giocatore';
GRANT EXECUTE ON procedure `mydb`.`stato_di_gioco` TO 'giocatore';
SET SQL_MODE = '';
DROP USER IF EXISTS moderatore;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'moderatore' IDENTIFIED BY 'moderatore';

GRANT EXECUTE ON procedure `mydb`.`crea_stanzadigioco` TO 'moderatore';
GRANT EXECUTE ON procedure `mydb`.`report_moderatore` TO 'moderatore';
GRANT EXECUTE ON procedure `mydb`.`aggiungi_moderatore` TO 'moderatore';
SET SQL_MODE = '';
DROP USER IF EXISTS login;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'login' IDENTIFIED BY 'login';

GRANT EXECUTE ON procedure `mydb`.`login` TO 'login';
GRANT EXECUTE ON procedure `mydb`.`aggiungi_giocatore` TO 'login';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `mydb`.`Utente`
-- -----------------------------------------------------
START TRANSACTION;
USE `mydb`;
INSERT INTO `mydb`.`Utente` (`nomeutente`, `password`, `tipo`, `armatedaposizionare`) VALUES ('luca', '6e6bc4e49dd477ebc98ef4046c067b5f', 'moderatore', NULL);
INSERT INTO `mydb`.`Utente` (`nomeutente`, `password`, `tipo`, `armatedaposizionare`) VALUES ('dominique', '6e6bc4e49dd477ebc98ef4046c067b5f', 'giocatore', NULL);
INSERT INTO `mydb`.`Utente` (`nomeutente`, `password`, `tipo`, `armatedaposizionare`) VALUES ('sissi', '6e6bc4e49dd477ebc98ef4046c067b5f', 'giocatore', NULL);
INSERT INTO `mydb`.`Utente` (`nomeutente`, `password`, `tipo`, `armatedaposizionare`) VALUES ('elis', '6e6bc4e49dd477ebc98ef4046c067b5f', 'giocatore', NULL);
INSERT INTO `mydb`.`Utente` (`nomeutente`, `password`, `tipo`, `armatedaposizionare`) VALUES ('leti', '6e6bc4e49dd477ebc98ef4046c067b5f', 'giocatore', NULL);
INSERT INTO `mydb`.`Utente` (`nomeutente`, `password`, `tipo`, `armatedaposizionare`) VALUES ('fra', '6e6bc4e49dd477ebc98ef4046c067b5f', 'giocatore', NULL);
INSERT INTO `mydb`.`Utente` (`nomeutente`, `password`, `tipo`, `armatedaposizionare`) VALUES ('mimmo', '6e6bc4e49dd477ebc98ef4046c067b5f', 'giocatore', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `mydb`.`Stanzadigioco`
-- -----------------------------------------------------
START TRANSACTION;
USE `mydb`;
INSERT INTO `mydb`.`Stanzadigioco` (`nomestanza`) VALUES ('verde');
INSERT INTO `mydb`.`Stanzadigioco` (`nomestanza`) VALUES ('blu');

COMMIT;


-- -----------------------------------------------------
-- Data for table `mydb`.`Stato`
-- -----------------------------------------------------
START TRANSACTION;
USE `mydb`;
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('ALASKA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('TERRITORI DEL NORD OVEST');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('GROENLANDIA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('ALBERTA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('ONTARIO');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('QUEBEC');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('STATI UNITI OCCIDENTALI');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('STATI UNITI ORIENTALI');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('AMERICA CENTRALE');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('VENEZUELA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('BRASILE');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('PERU');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('ARGENTINA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('ISLANDA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('GRAN BRETAGNA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('SCANDINAVIA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('EUROPA OCCIDENTALE');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('EUROPA SETTENTRIONALE');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('UCRAINA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('EUROPA MERIDIONALE');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('AFRICA DEL NORD');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('EGITTO');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('CONGO');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('AFRICA ORIENTALE');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('AFRICA DEL SUD');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('MADAGASCAR');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('URALI');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('SIBERIA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('JACUZIA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('KAMCHATKA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('CITA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('MEDIO ORIENTE');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('INDIA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('SIAM');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('INDONESIA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('NUOVA GUINEA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('AUSTRALIA OCCIDENTALE');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('AUSTRALIA ORIENTALE');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('GIAPPONE');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('CINA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('MONGOLIA');
INSERT INTO `mydb`.`Stato` (`nomestato`) VALUES ('AFGHANISTAN');

COMMIT;


-- -----------------------------------------------------
-- Data for table `mydb`.`Confina`
-- -----------------------------------------------------
START TRANSACTION;
USE `mydb`;
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ALASKA', 'TERRITORI DEL NORD OVEST');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ALASKA', 'ALBERTA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ALASKA', 'KAMCHATKA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('TERRITORI DEL NORD OVEST', 'ALASKA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('TERRITORI DEL NORD OVEST', 'GROENLANDIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('TERRITORI DEL NORD OVEST', 'ALBERTA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('TERRITORI DEL NORD OVEST', 'ONTARIO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('GROENLANDIA', 'TERRITORI DEL NORD OVEST');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('GROENLANDIA', 'ONTARIO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('GROENLANDIA', 'QUEBEC');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('GROENLANDIA', 'ISLANDA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ALBERTA', 'ALASKA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ALBERTA', 'TERRITORI DEL NORD OVEST');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ALBERTA', 'ONTARIO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ALBERTA', 'STATI UNITI OCCIDENTALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ONTARIO', 'GROENLANDIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ONTARIO', 'TERRITORI DEL NORD OVEST');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ONTARIO', 'QUEBEC');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ONTARIO', 'STATI UNITI OCCIDENTALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ONTARIO', 'STATI UNITI ORIENTALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ONTARIO', 'ALBERTA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('QUEBEC', 'GROENLANDIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('QUEBEC', 'ONTARIO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('QUEBEC', 'STATI UNITI ORIENTALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('STATI UNITI OCCIDENTALI', 'ALBERTA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('STATI UNITI OCCIDENTALI', 'ONTARIO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('STATI UNITI OCCIDENTALI', 'STATI UNITI ORIENTALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('STATI UNITI OCCIDENTALI', 'AMERICA CENTRALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('STATI UNITI ORIENTALI', 'STATI UNITI OCCIDENTALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('STATI UNITI ORIENTALI', 'ONTARIO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('STATI UNITI ORIENTALI', 'QUEBEC');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('STATI UNITI ORIENTALI', 'AMERICA CENTRALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AMERICA CENTRALE', 'STATI UNITI OCCIDENTALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AMERICA CENTRALE', 'STATI UNITI ORIENTALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AMERICA CENTRALE', 'VENEZUELA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('VENEZUELA', 'AMERICA CENTRALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('VENEZUELA', 'BRASILE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('VENEZUELA', 'PERU');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('BRASILE', 'VENEZUELA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('BRASILE', 'PERU');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('BRASILE', 'ARGENTINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('BRASILE', 'AFRICA DEL NORD');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('PERU', 'VENEZUELA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('PERU', 'BRASILE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('PERU', 'ARGENTINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ARGENTINA', 'PERU');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ARGENTINA', 'BRASILE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ISLANDA', 'GROENLANDIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ISLANDA', 'GRAN BRETAGNA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('ISLANDA', 'SCANDINAVIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('GRAN BRETAGNA', 'ISLANDA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('GRAN BRETAGNA', 'SCANDINAVIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('GRAN BRETAGNA', 'EUROPA OCCIDENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('GRAN BRETAGNA', 'EUROPA SETTENTRIONALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SCANDINAVIA', 'ISLANDA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SCANDINAVIA', 'GRAN BRETAGNA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SCANDINAVIA', 'EUROPA SETTENTRIONALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SCANDINAVIA', 'UCRAINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA OCCIDENTALE', 'GRAN BRETAGNA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA OCCIDENTALE', 'EUROPA SETTENTRIONALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA OCCIDENTALE', 'EUROPA MERIDIONALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA OCCIDENTALE', 'AFRICA DEL NORD');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA SETTENTRIONALE', 'GRAN BRETAGNA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA SETTENTRIONALE', 'SCANDINAVIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA SETTENTRIONALE', 'EUROPA OCCIDENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA SETTENTRIONALE', 'UCRAINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA SETTENTRIONALE', 'EUROPA MERIDIONALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('UCRAINA', 'SCANDINAVIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('UCRAINA', 'EUROPA SETTENTRIONALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('UCRAINA', 'EUROPA MERIDIONALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('UCRAINA', 'URALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('UCRAINA', 'AFGHANISTAN');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('UCRAINA', 'MEDIO ORIENTE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA MERIDIONALE', 'EUROPA OCCIDENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA MERIDIONALE', 'EUROPA SETTENTRIONALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA MERIDIONALE', 'UCRAINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA MERIDIONALE', 'MEDIO ORIENTE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA MERIDIONALE', 'AFRICA DEL NORD');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EUROPA MERIDIONALE', 'EGITTO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA DEL NORD', 'BRASILE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA DEL NORD', 'EUROPA OCCIDENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA DEL NORD', 'EUROPA MERIDIONALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA DEL NORD', 'EGITTO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA DEL NORD', 'CONGO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA DEL NORD', 'AFRICA ORIENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EGITTO', 'EUROPA MERIDIONALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EGITTO', 'AFRICA DEL NORD');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EGITTO', 'AFRICA ORIENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('EGITTO', 'MEDIO ORIENTE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CONGO', 'AFRICA DEL NORD');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CONGO', 'AFRICA ORIENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CONGO', 'AFRICA DEL SUD');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA ORIENTALE', 'AFRICA DEL NORD');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA ORIENTALE', 'EGITTO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA ORIENTALE', 'CONGO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA ORIENTALE', 'AFRICA DEL SUD');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA ORIENTALE', 'MADAGASCAR');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA DEL SUD', 'CONGO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA DEL SUD', 'AFRICA ORIENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFRICA DEL SUD', 'MADAGASCAR');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MADAGASCAR', 'AFRICA ORIENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MADAGASCAR', 'AFRICA DEL SUD');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('URALI', 'UCRAINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('URALI', 'SIBERIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('URALI', 'AFGHANISTAN');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('URALI', 'CINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SIBERIA', 'JACUZIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SIBERIA', 'URALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SIBERIA', 'CITA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SIBERIA', 'MONGOLIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SIBERIA', 'CINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('JACUZIA', 'SIBERIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('JACUZIA', 'KAMCHATKA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('JACUZIA', 'CITA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('KAMCHATKA', 'ALASKA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('KAMCHATKA', 'JACUZIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('KAMCHATKA', 'CITA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('KAMCHATKA', 'MONGOLIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('KAMCHATKA', 'GIAPPONE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CITA', 'SIBERIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CITA', 'JACUZIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CITA', 'KAMCHATKA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CITA', 'MONGOLIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('GIAPPONE', 'KAMCHATKA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('GIAPPONE', 'MONGOLIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFGHANISTAN', 'UCRAINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFGHANISTAN', 'URALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFGHANISTAN', 'CINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AFGHANISTAN', 'MEDIO ORIENTE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MONGOLIA', 'SIBERIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MONGOLIA', 'CITA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MONGOLIA', 'KAMCHATKA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MONGOLIA', 'CINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MONGOLIA', 'GIAPPONE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CINA', 'AFGHANISTAN');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CINA', 'URALI');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CINA', 'SIBERIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CINA', 'MONGOLIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CINA', 'SIAM');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CINA', 'INDIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('CINA', 'MEDIO ORIENTE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MEDIO ORIENTE', 'EUROPA MERIDIONALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MEDIO ORIENTE', 'AFGHANISTAN');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MEDIO ORIENTE', 'UCRAINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MEDIO ORIENTE', 'CINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MEDIO ORIENTE', 'INDIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('MEDIO ORIENTE', 'EGITTO');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('INDIA', 'CINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('INDIA', 'SIAM');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('INDIA', 'MEDIO ORIENTE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SIAM', 'INDIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SIAM', 'CINA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('SIAM', 'INDONESIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('INDONESIA', 'SIAM');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('INDONESIA', 'NUOVA GUINEA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('INDONESIA', 'AUSTRALIA OCCIDENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('NUOVA GUINEA', 'INDONESIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('NUOVA GUINEA', 'AUSTRALIA OCCIDENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('NUOVA GUINEA', 'AUSTRALIA ORIENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AUSTRALIA OCCIDENTALE', 'NUOVA GUINEA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AUSTRALIA OCCIDENTALE', 'INDONESIA');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AUSTRALIA OCCIDENTALE', 'AUSTRALIA ORIENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AUSTRALIA ORIENTALE', 'AUSTRALIA OCCIDENTALE');
INSERT INTO `mydb`.`Confina` (`stato`, `confinante`) VALUES ('AUSTRALIA ORIENTALE', 'NUOVA GUINEA');

COMMIT;

-- begin attached script 'script'
set global event_scheduler = ON;

delimiter !
CREATE EVENT if not exists `mydb`.`avvia_partita` 
ON SCHEDULE EVERY 2 second STARTS CURRENT_TIMESTAMP ON COMPLETION PRESERVE
comment "Quando il countdown di 2 minuti associato ad una partita scade, la partita viene avviata."
DO
BEGIN
	update Partita set statopartita = 'incorso'
		where now() > interval 2 minute + iniziocountdown and statopartita = 'inattesa';
END !

delimiter !
CREATE EVENT if not exists `mydb`.`controlla_turno` 
ON SCHEDULE EVERY 2 second STARTS CURRENT_TIMESTAMP ON COMPLETION PRESERVE
comment "Quando il timer di 2 minuti associato a un turno scade e non e' stata svolta alcuna azione, il turno passa al giocatore successivo."
DO
BEGIN
	declare var_tipoazione ENUM('posizionamento', 'spostamento', 'attacco', 'nonsvolta');
	declare var_giocatore VARCHAR(45);
    declare var_partita INT;
        
	update Turno set tipoazione = 'nonsvolta', tempoazione = now()
		where now() > interval 2 minute + inizioturno and tipoazione is null and tipoazione is null;
		
	select tipoazione, giocatore, partita
		from Turno
        order by tempoazione desc limit 1
        into var_tipoazione, var_giocatore, var_partita;
            
	if var_tipoazione = 'nonsvolta' then
		call turno_successivo(var_giocatore, var_partita);
	end if;
END !


delimiter !
create function `mydb`.`restituisci_partita` (var_giocatore VARCHAR(45))
returns INT
reads sql data
begin
	declare var_partita INT;

	select idpartita 
		from Gioca join Partita on Gioca.partita = Partita.idpartita
        where Gioca.giocatore = var_giocatore 
        order by idpartita desc limit 1
        into var_partita;        
	return var_partita;
END !

delimiter !
create function `mydb`.`restituisci_partita_incorso` (var_giocatore VARCHAR(45))
returns INT
reads sql data
begin
	declare var_partita INT;

	select idpartita 
		from Gioca join Partita on Gioca.partita = Partita.idpartita
        where Gioca.giocatore = var_giocatore and statopartita = 'incorso'
        into var_partita;        
	return var_partita;
END !
-- end attached script 'script'
