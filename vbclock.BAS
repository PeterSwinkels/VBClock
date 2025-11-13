OPTION EXPLICIT
DEFINT A-Z

DECLARE FUNCTION CurrentTime (Advance, NewHour, NewMinute, NewSecond) AS DOUBLE
DECLARE FUNCTION GetHours (SECONDS AS DOUBLE)
DECLARE FUNCTION GetMinutes (SECONDS AS DOUBLE)
DECLARE FUNCTION GetSeconds (SECONDS AS DOUBLE)
DECLARE SUB DrawClock (DisplayedTime AS DOUBLE)
DECLARE SUB Initialize ()
DECLARE SUB Main ()
DECLARE SUB Quit ()

CONST FALSE = 0
CONST NONE = -1
CONST TRUE = -1

CONST BACKGROUND = 0
CONST CLOCK_SIZE = 190
CONST HAND_NUT_SIZE = 3
CONST HOURS_TO_DEGREES = 30
CONST LARGE_MARK_INTERVAL = 3
CONST MINUTES_TO_DEGREES = 6
CONST MINUTES_TO_FRACTION# = 1 / 60
CONST PI# = 3.14159265358979#
CONST SECONDS_PER_HOUR = 3600
CONST SECONDS_PER_MINUTE = 60
CONST SECONDS_TO_DEGREES = 6
CONST TWELVE_HOUR_ANGLE = -90

CONST CLOCKX = CLOCK_SIZE * 1.5
CONST CLOCKY = CLOCK_SIZE * 1.1
CONST DEGREES_PER_RADIAN# = 180 / PI#
CONST HOUR_HAND_LENGTH = CLOCK_SIZE / 1.6
CONST LARGE_MARK_LENGTH = HOUR_HAND_LENGTH / 2.5
CONST MINUTE_HAND_LENGTH = HOUR_HAND_LENGTH * 1.5
CONST SECOND_HAND_LENGTH = HOUR_HAND_LENGTH * 1.5
CONST SMALL_MARK_LENGTH = LARGE_MARK_LENGTH / 2

ON TIMER(1) GOSUB ClockTick
Initialize
CALL Main
Quit
END

ClockTick:
DrawClock CurrentTime(TRUE, NONE, NONE, NONE)
RETURN

FUNCTION CurrentTime (Advance, NewHour, NewMinute, NewSecond) AS DOUBLE
STATIC SECONDS AS DOUBLE

   IF Advance THEN
      IF GetSeconds(SECONDS) = 59 THEN
         SECONDS = (GetHours(SECONDS) * CLNG(SECONDS_PER_HOUR)) + (GetMinutes(SECONDS) * SECONDS_PER_MINUTE)
         IF GetMinutes(SECONDS) = 59 THEN
            SECONDS = GetHours(SECONDS) * SECONDS_PER_HOUR
            IF GetHours(SECONDS) = 11 THEN
               SECONDS = 0
            ELSE
               SECONDS = SECONDS + SECONDS_PER_HOUR
            END IF
         ELSE
            SECONDS = SECONDS + SECONDS_PER_MINUTE
         END IF
      ELSE
         SECONDS = SECONDS + 1
      END IF
   ELSE
      IF NOT NewHour = NONE THEN
         SECONDS = GetSeconds(SECONDS) + (GetMinutes(SECONDS) * SECONDS_PER_MINUTE) + (NewHour * CLNG(SECONDS_PER_HOUR))
      END IF
      IF NOT NewMinute = NONE THEN
         SECONDS = GetSeconds(SECONDS) + (NewMinute * SECONDS_PER_MINUTE) + (GetHours(SECONDS) * CLNG(SECONDS_PER_HOUR))
      END IF
      IF NOT NewSecond = NONE THEN
         SECONDS = NewSecond + (GetMinutes(SECONDS) * SECONDS_PER_MINUTE) + (GetHours(SECONDS) * CLNG(SECONDS_PER_HOUR))
      END IF
   END IF

   CurrentTime = SECONDS
END FUNCTION

SUB DrawClock (DisplayedTime AS DOUBLE)
DIM HourAsRadians AS DOUBLE
DIM HourOnFace
DIM MarkLength
DIM MinuteAsRadians AS DOUBLE
DIM SecondAsRadians AS DOUBLE

STATIC HourHandX
STATIC HourHandY
STATIC MinuteHandX
STATIC MinuteHandY
STATIC SecondHandX
STATIC SecondHandY

   LINE (CLOCKX, CLOCKY)-(HourHandX, HourHandY), BACKGROUND
   LINE (CLOCKX, CLOCKY)-(MinuteHandX, MinuteHandY), BACKGROUND
   LINE (CLOCKX, CLOCKY)-(SecondHandX, SecondHandY), BACKGROUND

   FOR HourOnFace = 0 TO 11
      HourAsRadians = ((HourOnFace * HOURS_TO_DEGREES) + TWELVE_HOUR_ANGLE) / DEGREES_PER_RADIAN#
      IF HourOnFace MOD LARGE_MARK_INTERVAL = 0 THEN MarkLength = LARGE_MARK_LENGTH ELSE MarkLength = SMALL_MARK_LENGTH
      LINE ((COS(HourAsRadians) * CLOCK_SIZE) + CLOCKX, (SIN(HourAsRadians) * CLOCK_SIZE) + CLOCKY)-((COS(HourAsRadians) * (CLOCK_SIZE - MarkLength)) + CLOCKX, (SIN(HourAsRadians) * (CLOCK_SIZE - MarkLength)) + CLOCKY), 14
   NEXT HourOnFace
   CIRCLE (CLOCKX, CLOCKY), CLOCK_SIZE, 1

   HourAsRadians = (((GetHours(DisplayedTime) + GetMinutes(DisplayedTime) * MINUTES_TO_FRACTION#) * HOURS_TO_DEGREES) + TWELVE_HOUR_ANGLE) / DEGREES_PER_RADIAN#
   SecondAsRadians = ((GetSeconds(DisplayedTime) * SECONDS_TO_DEGREES) + TWELVE_HOUR_ANGLE) / DEGREES_PER_RADIAN#
   MinuteAsRadians = ((GetMinutes(DisplayedTime) * MINUTES_TO_DEGREES) + TWELVE_HOUR_ANGLE) / DEGREES_PER_RADIAN#

   HourHandX = (COS(HourAsRadians) * HOUR_HAND_LENGTH) + CLOCKX
   HourHandY = (SIN(HourAsRadians) * HOUR_HAND_LENGTH) + CLOCKY
   MinuteHandX = (COS(MinuteAsRadians) * MINUTE_HAND_LENGTH) + CLOCKX
   MinuteHandY = (SIN(MinuteAsRadians) * MINUTE_HAND_LENGTH) + CLOCKY
   SecondHandX = (COS(SecondAsRadians) * SECOND_HAND_LENGTH) + CLOCKX
   SecondHandY = (SIN(SecondAsRadians) * SECOND_HAND_LENGTH) + CLOCKY

   LINE (CLOCKX, CLOCKY)-(HourHandX, HourHandY), 2
   LINE (CLOCKX, CLOCKY)-(MinuteHandX, MinuteHandY), 2
   LINE (CLOCKX, CLOCKY)-(SecondHandX, SecondHandY), 4
   CIRCLE (CLOCKX, CLOCKY), HAND_NUT_SIZE, 15
END SUB

FUNCTION GetHours (SECONDS AS DOUBLE)
   GetHours = INT(SECONDS / SECONDS_PER_HOUR)
END FUNCTION

FUNCTION GetMinutes (SECONDS AS DOUBLE)
   GetMinutes = INT((SECONDS - (GetHours(SECONDS) * CDBL(SECONDS_PER_HOUR))) / SECONDS_PER_MINUTE)
END FUNCTION

FUNCTION GetSeconds (SECONDS AS DOUBLE)
   GetSeconds = INT(SECONDS - (GetHours(SECONDS) * CDBL(SECONDS_PER_HOUR)) - (GetMinutes(SECONDS) * CDBL(SECONDS_PER_MINUTE)))
END FUNCTION

SUB Initialize ()
   SCREEN 12
   WIDTH 80, 30
   CLS
   COLOR 3
   TIMER ON
END SUB

SUB Main ()
DIM KeyCode AS STRING
DIM SECONDS AS DOUBLE

   SECONDS = CurrentTime(FALSE, GetHours(TIMER), GetMinutes(TIMER), GetSeconds(TIMER))
   DrawClock CurrentTime(FALSE, NONE, NONE, NONE)

   LOCATE (CLOCK_SIZE / 8) + 3, 1
   PRINT "   VBClock v1.00 - by: Peter Swinkels, ***2025***"
   PRINT "   Press the a or A keys to quickly advance the time. Escape = quit"

   DO
      DO
         KeyCode = INKEY$
      LOOP WHILE KeyCode = ""
      SELECT CASE KeyCode
         CASE "a", "A"
            SECONDS = CurrentTime(FALSE, NONE, NONE, NONE)
            IF KeyCode$ = "A" THEN
               IF GetHours(SECONDS) = 11 THEN SECONDS = 0 ELSE SECONDS = SECONDS + SECONDS_PER_HOUR
            ELSE
               IF GetMinutes(SECONDS) = 59 THEN
                  SECONDS = GetHours(SECONDS) * CLNG(SECONDS_PER_HOUR)
                  IF GetHours(SECONDS) = 11 THEN SECONDS = 0 ELSE SECONDS = SECONDS + SECONDS_PER_HOUR
               ELSE
                  SECONDS = SECONDS + SECONDS_PER_MINUTE
               END IF
            END IF
            DrawClock CurrentTime#(FALSE, GetHours(SECONDS), GetMinutes(SECONDS), NONE)
         CASE CHR$(27)
            EXIT DO
      END SELECT
   LOOP
END SUB

SUB Quit ()
   TIMER OFF
   SCREEN 0
   WIDTH 80, 25
   COLOR 7, 0
   CLS
   SYSTEM
END SUB

