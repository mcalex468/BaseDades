-- JOINS --

/*1. Mostra els noms de tots els venedors i si tenen assigant un cap mostra el nom del seu cap
com a "cap.*/
SELECT r.nombre AS "NomVenedors" , d.director AS "Cap"
FROM repventas r LEFT JOIN d repventas
ON r.director = d.num_empl


