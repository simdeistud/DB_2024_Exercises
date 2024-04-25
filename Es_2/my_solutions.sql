/* QUERY 5.1 */
/* Mostrare la media ponderata di ogni studente (mostrate matricola, nome e
cognome di ogni studente) */

SELECT studente,
       studenti.nome,
       studenti.cognome,
       SUM(voto * cfu) / SUM(cfu) AS 'media ponderata'
FROM esami
         INNER JOIN corsi ON esami.corso = corsi.codice
         INNER JOIN studenti ON esami.studente = studenti.matricola
GROUP BY studente;

/* QUERY 6 */
/* Quali studenti non hanno mai preso una lode? */
SELECT studente
FROM esami
GROUP BY studente
HAVING SUM(lode) = 0;

/* QUERY 7 */
/* Quali docenti svolgono un monte ore annuo minore di 120 ore? */
SELECT p.matricola, p.cognome, p.nome, SUM(c.cfu * 8) AS 'monte ore'
FROM professori p
         INNER JOIN corsi c ON matricola = professore
GROUP BY matricola
HAVING `monte ore` < 120;

/* QUERY 8 */
/* Verificare se ci sono casi di omonimia tra studenti e/o professori */
SELECT nome, cognome, COUNT(*) AS n_omonimie
FROM (SELECT nome, cognome
      FROM studenti
      UNION ALL
      SELECT nome, cognome
      FROM professori) AS t
GROUP BY nome, cognome
ORDER BY n_omonimie DESC;

/* PREPARED STATEMENT 1 */
/* Creare un prepared statement che mostri tutti gli studenti appartenenti ad un corso
di laurea passato come parametro */
PREPARE ps_courseStudents FROM
    'SELECT * FROM studenti WHERE matricola LIKE CONCAT(?, "%")';
SET @corso_studi = "IN05";
EXECUTE ps_courseStudents USING @corso_studi;

/* PREPARED STATEMENT 2 */
/* Creare un prepared statement che mostri tutti gli studenti che hanno superato
l’esame di un dato corso, il cui codice è passato come parametro */
PREPARE ps_passedStudents FROM
    'SELECT studente FROM esami WHERE corso = ?';
SET @corso = "079IN";
EXECUTE ps_passedStudents USING @corso;

/* VISTA 1 */
/* Quali sono i voti preferiti di ogni professore? */

CREATE VIEW favorite_marks AS
SELECT p.matricola, p.cognome, p.nome, voto, COUNT(*) AS n_assegnazioni
FROM professori p
         INNER JOIN corsi ON p.matricola = corsi.professore
         INNER JOIN esami ON corsi.codice = esami.corso
GROUP BY p.matricola, voto;

SELECT DISTINCT matricola, cognome, voto
FROM favorite_marks t1
WHERE n_assegnazioni = (SELECT MAX(n_assegnazioni)
                        from favorite_marks t2
                        WHERE t1.matricola = t2.matricola)

/* VISTA 2 */
/* Quali sono i gli studenti più bravi per ogni corso di laurea? */
