---------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- PROJECT_QUESTIONS.SQL --------------------------------------------------
----------------------------------------------------- Airport Data Base ---------------------------------------------------
------------------------------------------------------ College LaSalle ----------------------------------------------------
----------------------------------------------- Advanced Data Base Final Project ------------------------------------------
--																											
-- Name: Francisco Maldonado
-- No.: 1170940
--
--
-- Teacher: Iryna Projorovskaia
--
--
-- Description: App to manage flights data of an airport 

CLEAR SCR

-------------------------------------------------------------------------
-- CREATING FUNCTION is_number to use as a tool in some exercises
-------------------------------------------------------------------------
-------------------------------------------------------------------------
PROMPT +++++++++++++++++CREATING FUNCTION IS_NUMBER++++++++++++++++++++++
CREATE OR REPLACE 
FUNCTION is_number (V_SP_STRING IN VARCHAR2)
RETURN BOOLEAN
IS
	V_TEST_NUMBER NUMBER;

BEGIN
	V_TEST_NUMBER:=V_SP_STRING;
	RETURN TRUE;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN FALSE;
END is_number;
/		
-------------------------------------------------------------------------
-------------------------------------------------------------------------

SET SERVEROUTPUT ON
SET VERIFY OFF



-- 1. Type a PL/SQL program that displays the (id, description, max passenger 
-- and city name) for all planes located in the given city (city name) and 
-- their max passenger is greater or equal to a given number.
PROMPT *********************** QUESTION #1 ******************************

ACCEPT S_CITY PROMPT 'ENTER A CITY: ';
ACCEPT S_MAXPASS PROMPT 'ENTER A QUANTITY OF PASSENGERS: ';

DECLARE
	TYPE R_PLANE IS RECORD(
		V_PID 		PLANE.PLA_ID%TYPE,
		V_DESC		PLANE.PLA_DESC%TYPE,
		V_MAXPASS	PLANE.MAX_PASSENGER%TYPE,
		V_CITY 		CITY.CITY_NAME%TYPE);
		
	TYPE T_PLANE IS TABLE OF R_PLANE;

	V_PLANE 	T_PLANE;
V_IS_NUMBER_FLAG		BOOLEAN;
E_NOT_NUMBER 			EXCEPTION;
V_PRUEBA				VARCHAR2(4):='&S_MAXPASS';

BEGIN
	V_IS_NUMBER_FLAG := is_number( V_PRUEBA );
	
	IF V_IS_NUMBER_FLAG = FALSE THEN
		RAISE E_NOT_NUMBER;
	ELSE 
		SELECT P.PLA_ID, P.PLA_DESC , P.MAX_PASSENGER , C.CITY_NAME
		BULK COLLECT
		INTO V_PLANE
		FROM PLANE P , CITY C
		WHERE P.MAX_PASSENGER BETWEEN '&S_MAXPASS' AND 500 AND C.CITY_NAME = UPPER('&S_CITY') AND C.CITY_ID = P.CITY_ID;
	
		IF SQL%FOUND THEN
			DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
			DBMS_OUTPUT.PUT_LINE('ID	DESCRIPTION	MAX PASSENGERS	CITY');
			DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
		
			FOR I IN V_PLANE.FIRST..V_PLANE.LAST LOOP
				DBMS_OUTPUT.PUT_LINE(RPAD(V_PLANE(I).V_PID, 8 , ' ')||
									RPAD(V_PLANE(I).V_DESC, 16, ' ')||
									RPAD(V_PLANE(I).V_MAXPASS, 16, ' ')||
									V_PLANE(I).V_CITY);
	
						 
			END LOOP;
		ELSE 
			RAISE NO_DATA_FOUND;
		END IF;	
			
			
	END IF;

	
	EXCEPTION
		WHEN E_NOT_NUMBER THEN
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			DBMS_OUTPUT.PUT_LINE('VALUE ENTERED IS NOT A NUMBER');
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			DBMS_OUTPUT.PUT_LINE('THERE ARE NO DATA... ' || SQLERRM);
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			DBMS_OUTPUT.PUT_LINE('ENTER A VALID VALUE... ' || SQLERRM);
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		

END;
/

-- 2. a) Create the stored function NbOfPlanesPerCity that accepts the 
-- 		 parameter: city name and returns the total number of planes located in that city.
PROMPT *********************** QUESTION #2 ******************************
PROMPT ===== (PART A CREATING FUNCTION NbOfPlanesPerCity)

CREATE OR REPLACE FUNCTION NbOfPlanesPerCity(FCITY_NAME IN CITY.CITY_NAME%TYPE)
RETURN NUMBER 
IS V_TOTAL_PLANES NUMBER;
BEGIN
	SELECT COUNT(P.CITY_ID)
	INTO V_TOTAL_PLANES
	FROM PLANE P , CITY C
	WHERE C.CITY_NAME = FCITY_NAME AND P.CITY_ID = C.CITY_ID; 
	
	RETURN(V_TOTAL_PLANES);
END NbOfPlanesPerCity;
/

-- 2. b) Test the function NbOfPlanesPerCity (the city name can be entered in upper or lower case) 
-- (the function must inform the user when the city doesn’t exit)

PROMPT ===== (PART B TESTING FUNCTION NbOfPlanesPerCity)

ACCEPT S_CITY PROMPT 'ENTER THE CITY NAME: ';

DECLARE
	V_PLANES_NUMBERS	NUMBER;
BEGIN
	V_PLANES_NUMBERS:= NbOfPlanesPerCity(UPPER('&S_CITY'));
	
	IF V_PLANES_NUMBERS = 0 THEN
		DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		DBMS_OUTPUT.PUT_LINE('THE CITY DOESN''T EXIST');
		DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
	ELSE
		DBMS_OUTPUT.PUT_LINE('---------------------------');
		DBMS_OUTPUT.PUT_LINE('CITY		N PLANES');
		DBMS_OUTPUT.PUT_LINE('---------------------------');
		DBMS_OUTPUT.PUT_LINE(RPAD('&S_CITY',16,' ')||V_PLANES_NUMBERS);
	END IF;
	
END;
/


-- 3. a) Create the stored procedure ListOfFlights that accepts the parameter : 
-- city name (departure city) and displays the list of flights ordered in ascending 
-- order of departure time (the columns to display are : flight id, pilot name, plane 
-- description, departure time, arrival time, arrival city name)
PROMPT *********************** QUESTION #3 ******************************
PROMPT ===== (PART A CREATING PROCEDURE ListOfFlights)

CREATE OR REPLACE PROCEDURE ListOfFlights(DEP_CITY IN CITY.CITY_NAME%TYPE)
IS
	TYPE R_FLIGHT IS RECORD(
		V_FLIGHT_ID		 FLIGHT.FLIGHT_ID%TYPE,
		V_PILOT_NAME	 PILOT.LAST_NAME%TYPE,
		V_PLANE_DESC	 PLANE.PLA_DESC%TYPE,
		V_DEP_TIME		 FLIGHT.DEP_TIME%TYPE,
		V_ARR_TIME		 FLIGHT.ARR_TIME%TYPE,
		V_ARR_CITY		 CITY.CITY_NAME%TYPE);
		
	TYPE T_FLIGHT IS TABLE OF R_FLIGHT;
	V_FLIGHT	 T_FLIGHT;
		
BEGIN

	SELECT F.FLIGHT_ID , P.LAST_NAME , PL.PLA_DESC , F.DEP_TIME , F.ARR_TIME , C1.CITY_NAME
	BULK COLLECT
	INTO V_FLIGHT
	FROM FLIGHT F , PILOT P , PLANE PL , CITY C1 , CITY C2
	WHERE C2.CITY_NAME = DEP_CITY AND C2.CITY_ID = F.CITY_DEP AND 
		  C1.CITY_ID = F.CITY_ARR AND F.PLA_ID = PL.PLA_ID AND 
		  F.PILOT_ID = P.PILOT_ID
	ORDER BY F.DEP_TIME ASC;
		
	IF SQL%FOUND THEN
		DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
		DBMS_OUTPUT.PUT_LINE('FLIGHT	PILOT NAME	PLANE DESC	DEP_TIME	ARR_TIME	ARR_CITY');
		DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');	
		FOR I IN V_FLIGHT.FIRST .. V_FLIGHT.LAST LOOP
			DBMS_OUTPUT.PUT_LINE(RPAD(V_FLIGHT(I).V_FLIGHT_ID,8,' ')||
								RPAD(V_FLIGHT(I).V_PILOT_NAME,16,' ')||
								RPAD(V_FLIGHT(I).V_PLANE_DESC,16,' ')||
								RPAD(V_FLIGHT(I).V_DEP_TIME,16,' ')||
								RPAD(V_FLIGHT(I).V_ARR_TIME,16,' ')||
								V_FLIGHT(I).V_ARR_CITY);
		END LOOP;
	ELSE	
		DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		DBMS_OUTPUT.PUT_LINE('THERE IS NO DATA ABOUT THAT CITY');
		DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
	END IF;
							 
	EXCEPTION 
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			DBMS_OUTPUT.PUT_LINE('THERE IS NO DATA ');
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			DBMS_OUTPUT.PUT_LINE('ERROR...'||SQLERRM);
		
END ListOfFlights;
/


-- 3. b) Test the procedure ListOfFlights (the city name can be entered 
-- in upper or lower case)

PROMPT ===== (PART B TESTING PROCEDURE ListOfFlights)

ACCEPT S_CITY PROMPT 'ENTER THE CITY NAME: ';

BEGIN
		
	-- CALLING PROCEDURE
	ListOfFlights(UPPER('&S_CITY'));
	
	
END;
/
	
	
-- 4. Create the package specification and the package body FlightPackage. This package contains:
-- InfoFlight: Accepts the parameter: the flight id and displays the following information:
-- Pilot name;
-- Plane description;
-- Departure city name;
-- Arrival city name;
-- Departure time;
-- Arrival time;
-- Duration of the flight (expressed in hour minute second): use the function NUMTODSINTERVAL.

-- NbFlightPerPilot: Returns the number of flight made by a particular pilot (pilot id).

-- NbFlightInterval: returns the number of flight where the departure time is between two values.

PROMPT *********************** QUESTION #4 ******************************
PROMPT ===== (PART A CREATING PACKAGE FlightPackage)

CREATE OR REPLACE PACKAGE FlightPackage
AS 

	PROCEDURE InfoFlight( P_FL_ID IN NUMBER );
	FUNCTION NbFlightPerPilot( F_PILOT_ID IN NUMBER )
		RETURN NUMBER;
	FUNCTION NbFlightInterval( F_FIRST_TIME IN NUMBER , F_SECOND_TIME IN NUMBER)
		RETURN NUMBER;
END FlightPackage;
/

CREATE OR REPLACE PACKAGE BODY FlightPackage
AS

	PROCEDURE InfoFlight( P_FL_ID IN NUMBER )
	IS
	
		V_PILOT_NAME	PILOT.LAST_NAME%TYPE;
		V_PLANE_DESC	PLANE.PLA_DESC%TYPE;
		V_DEPART_CITY	CITY.CITY_NAME%TYPE;
		V_ARRIV_CITY	CITY.CITY_NAME%TYPE;
		V_DEP_TIME		FLIGHT.DEP_TIME%TYPE;
		V_ARR_TIME		FLIGHT.ARR_TIME%TYPE;
		V_FL_DURAT		NUMBER;
		V_TEMP			NUMBER;

	BEGIN
		SELECT P.LAST_NAME , PL.PLA_DESC , C.CITY_NAME , C2.CITY_NAME , F.DEP_TIME , F.ARR_TIME
		INTO V_PILOT_NAME , V_PLANE_DESC , V_DEPART_CITY , V_ARRIV_CITY , V_DEP_TIME , V_ARR_TIME
		FROM PILOT P , PLANE PL , CITY C , CITY C2 , FLIGHT F
		WHERE F.FLIGHT_ID = P_FL_ID AND PL.PLA_ID= F.PLA_ID AND F.PILOT_ID = P.PILOT_ID AND C.CITY_ID = F.CITY_DEP AND C2.CITY_ID = F.CITY_ARR;
		
		V_TEMP := TRUNC((V_ARR_TIME - V_DEP_TIME)/100);
		
		-- ADAPTING INTERVAL TO MAKE A RIGHT TIME DURATION
		IF	V_TEMP > 0 THEN	
			V_FL_DURAT := V_ARR_TIME - V_DEP_TIME - V_TEMP*40;
		ELSE
			V_FL_DURAT := V_ARR_TIME - V_DEP_TIME - 40;
		END IF;
		
		DBMS_OUTPUT.PUT_LINE('-------------------------------------');
		DBMS_OUTPUT.PUT_LINE('PILOT NAME :'||V_PILOT_NAME);
		DBMS_OUTPUT.PUT_LINE('PLANE DESCRIPTION :'||V_PLANE_DESC);
		DBMS_OUTPUT.PUT_LINE('DEPARTURE CITY :'||V_DEPART_CITY);
		DBMS_OUTPUT.PUT_LINE('ARRIVAL CITY :'||V_ARRIV_CITY);
		DBMS_OUTPUT.PUT_LINE('DEPARTURE TIME :'||V_DEP_TIME);
		DBMS_OUTPUT.PUT_LINE('ARRIVAL TIME :'||V_ARR_TIME);
		DBMS_OUTPUT.PUT_LINE('DURATION  :'||NUMTODSINTERVAL(V_FL_DURAT ,'MINUTE'));
		DBMS_OUTPUT.PUT_LINE('DURATION IN MINUTES :'||V_FL_DURAT);
			
		
	END InfoFlight;
	
	FUNCTION NbFlightPerPilot( F_PILOT_ID IN NUMBER )
	RETURN NUMBER
	IS
	V_FLIGHTS_COUNT	NUMBER;
	BEGIN
		SELECT COUNT(FLIGHT_ID)
		INTO V_FLIGHTS_COUNT
		FROM FLIGHT
		WHERE PILOT_ID = F_PILOT_ID;
		
		RETURN (V_FLIGHTS_COUNT);
		
	END NbFlightPerPilot;
	
	FUNCTION NbFlightInterval( F_FIRST_TIME IN NUMBER , F_SECOND_TIME IN NUMBER )
	RETURN NUMBER
	IS
	V_FLIGHTS_COUNT	NUMBER;
	BEGIN
		SELECT COUNT(FLIGHT_ID)
		INTO V_FLIGHTS_COUNT
		FROM FLIGHT
		WHERE DEP_TIME BETWEEN F_FIRST_TIME AND F_SECOND_TIME;
		
		RETURN (V_FLIGHTS_COUNT);
		
	END NbFlightInterval;
	
	

END FlightPackage;
/

-----------------------------------------------------------------------
PROMPT ===== (TESTING PACKAGE FlightPackage.InfoFlight)

ACCEPT S_FLIGHT_ID PROMPT 'ENTER A FLIGHT ID: '

DECLARE 
V_IS_NUMBER_FLAG		BOOLEAN;
E_NOT_NUMBER 			EXCEPTION;
V_PRUEBA				VARCHAR2(4):='&S_FLIGHT_ID';

BEGIN
	V_IS_NUMBER_FLAG := is_number( V_PRUEBA );
	
	IF V_IS_NUMBER_FLAG = FALSE THEN
		RAISE E_NOT_NUMBER;
	ELSE 
		FlightPackage.InfoFlight( V_PRUEBA );
		
	END IF;
	
	EXCEPTION
		WHEN E_NOT_NUMBER THEN
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			DBMS_OUTPUT.PUT_LINE('VALUE ENTERED IS NOT A NUMBER');
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			DBMS_OUTPUT.PUT_LINE('ERROR...'||SQLERRM);
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
END;
/
	
-----------------------------------------------------------------------	
PROMPT ===== (TESTING PACKAGE FlightPackage.NbFlightPerPilot)

ACCEPT S_PILOT_ID PROMPT 'ENTER A PILOT ID: '

DECLARE 
V_IS_NUMBER_FLAG		BOOLEAN;
E_NOT_NUMBER 			EXCEPTION;
V_PRUEBA				VARCHAR2(4):='&S_PILOT_ID';
V_FLIGHTS_COUNT			NUMBER;

BEGIN
	V_IS_NUMBER_FLAG := is_number( V_PRUEBA );
	
	IF V_IS_NUMBER_FLAG = FALSE OR V_PRUEBA IS NULL THEN
		RAISE E_NOT_NUMBER;
	ELSE 
		V_FLIGHTS_COUNT := FlightPackage.NbFlightPerPilot( V_PRUEBA );
		
		DBMS_OUTPUT.PUT_LINE('-------------------------------------');
		DBMS_OUTPUT.PUT_LINE('PILOT Number '||V_PRUEBA|| ' MAKES '|| V_FLIGHTS_COUNT || ' FLIGHTS.');
		DBMS_OUTPUT.PUT_LINE('-------------------------------------');
		
	END IF;
	
	EXCEPTION
		WHEN E_NOT_NUMBER THEN
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			DBMS_OUTPUT.PUT_LINE('VALUE ENTERED IS NOT A NUMBER');
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			DBMS_OUTPUT.PUT_LINE('ERROR...'||SQLERRM);
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
END;
/
		
-----------------------------------------------------------------------	

-----------------------------------------------------------------------	
PROMPT ===== (TESTING PACKAGE FlightPackage.NbFlightInterval)

ACCEPT S_FIRST_TIME PROMPT 'ENTER THE FIRST TIME: '
ACCEPT S_SECOND_TIME PROMPT 'ENTER THE FIRST TIME: '

DECLARE 
V_IS_NUMBER_FLAG1		BOOLEAN;
V_IS_NUMBER_FLAG2		BOOLEAN;
E_NOT_NUMBER 			EXCEPTION;
V_PRUEBA1				VARCHAR2(4):='&S_FIRST_TIME';
V_PRUEBA2				VARCHAR2(4):='&S_SECOND_TIME';
V_FLIGHTS_COUNT			NUMBER;

BEGIN
	V_IS_NUMBER_FLAG1 := is_number( V_PRUEBA1 );
	V_IS_NUMBER_FLAG2 := is_number( V_PRUEBA2 );
	
	IF V_IS_NUMBER_FLAG1 = FALSE OR V_IS_NUMBER_FLAG2 = FALSE  OR V_PRUEBA1 IS NULL OR V_PRUEBA2 IS NULL THEN
		RAISE E_NOT_NUMBER;
	ELSE 
		V_FLIGHTS_COUNT := FlightPackage.NbFlightInterval( V_PRUEBA1 , V_PRUEBA2 );
		
		DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------');
		DBMS_OUTPUT.PUT_LINE('THE NUMBERS OF FLIGHTS BETWEEN '||V_PRUEBA1|| ' AND '|| V_PRUEBA2 || ' ARE ' || V_FLIGHTS_COUNT );
		DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------');
		
	END IF;
	
	EXCEPTION
		WHEN E_NOT_NUMBER THEN
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			DBMS_OUTPUT.PUT_LINE('VALUE ENTERED IS NOT A NUMBER');
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			DBMS_OUTPUT.PUT_LINE('ERROR...'||SQLERRM);
			DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
END;
/
		
-----------------------------------------------------------------------	
 
	
	
	
	
	
	
	
	
	
	
	








