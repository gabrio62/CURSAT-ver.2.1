REM Display of the initial screen
DIM NC AS INTEGER
DIM NS AS INTEGER
DIM NR AS INTEGER
DIM Q AS INTEGER
CLS
COLOR 15: PRINT "CURSAT  ver 2.1  Edition #2 - A simple, resampling-based, program to generate"
PRINT "pseudoreplicates of data and calculate rarefaction curves": PRINT
PRINT "Gabriele Gentile, Department of Biology, University TOR VERGATA"
PRINT "Via della Ricerca Scientifica, 1 - 00133, Rome, Italy"
PRINT "E-mail: gabriele.gentile@uniroma2.it"
PRINT

COLOR 14: PRINT "Note:"; SPC(0): COLOR 15: PRINT "This edition will allow you to keep full track of the resampling procedure"
PRINT "by generating a log file. For each replicate, the log file will incorporate"
PRINT "information relative to intermediate matrices. Such matrices are functional"
PRINT "to the generation of resampled data and accumulation matrices. Please use"
PRINT "Edition #1 for analysis with large datasets or high number of replicates."
PRINT: PRINT
COLOR 10: PRINT "License statement: "; SPC(0): COLOR 15: PRINT "This software may be used and distributed as regulated by the MIT license"

REM Copyright <2020> <Gabriele Gentile>
REM Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
REM The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

PRINT: PRINT: PRINT
PRINT "PRESS A KEY TO CONTINUE"
SLEEP
DO
    k$ = INKEY$
LOOP UNTIL k$ = ""

CLS

REM  input of number of repetitions, seed number, and filenames
REM  Dimensioning input data matrix D(NS, NC), pseudomatrix ND(NS,NC), and "incidence" matrix B(NS,NC)

DIM lg AS STRING
PRINT

INPUT "How many columns (sampling events)"; NC
INPUT "How many rows (species, OTUs, objects"; NS
INPUT "How many repetitions"; NR
INPUT "Seed number"; sd$: seed = VAL(sd$)
INPUT "Log filename:"; lg$
DIM D(NS, NC), ND(NS, NC), B(NS, NC)

INPUT "Input filename"; inpu$
INPUT "Accumulation pseudoreplicates' filename"; file$
INPUT "Dataset pseudoreplicates' filename"; boot$
CLS

REM Opening files for accumulation-pseudoreplicates (file$), dataset-pseudoreplicates (boot$), and log (lg$) output files

OPEN file$ FOR OUTPUT AS #1
OPEN boot$ FOR OUTPUT AS #2
OPEN lg$ FOR OUTPUT AS #4

BEGINTIME$ = TIME$

REM Printing to accumulation-pseudoreplicates (file$) output file

PRINT #1, "CURSAT ver 2.1 Edition #2 ", "Date: ", DATE$, "  Hour: ", BEGINTIME$
PRINT #1, "Input file:  ", inpu$
PRINT #1, "Accumulation pseudoreplicates' file: ", file$
PRINT #1, "Dataset pseudoreplicates' file: ", boot$
PRINT #1, "Number of columns (sampling events): ", NC
PRINT #1, "Number of rows (species, OTUs, objects,...): ", NS
PRINT #1, "Number of repetitions: ", NR
PRINT #1, "Seed number: ", sd$
PRINT #1, "Log filename: ", lg$
PRINT #1,

REM Printing to dataset-pseudoreplicates (boot$) output file

PRINT #2, "CURSAT ver 2.1 Edition #2 ", "Date: ", DATE$, "  Hour: ", BEGINTIME$
PRINT #2, "Input file:  ", inpu$
PRINT #2, "Accumulation pseudoreplicates' file: ", file$
PRINT #2, "Dataset pseudoreplicates' file: ", boot$
PRINT #2, "Number of columns: ", NC
PRINT #2, "Number of rows: ", NS
PRINT #2, "Number of repetitions: ", NR
PRINT #2, "Seed number: ", sd$
PRINT #2, "Log filename: ", lg$
PRINT #2,

REM Printing to log (lg$) output file

PRINT #4, "CURSAT ver 2.1 Edition #2 ", "Date: ", DATE$, "  Hour: ", BEGINTIME$
PRINT #4, "Input file:  ", inpu$
PRINT #4, "Accumulation pseudoreplicates' file: ", file$
PRINT #4, "Dataset pseudoreplicates' file: ", boot$
PRINT #4, "Number of columns: ", NC
PRINT #4, "Number of rows: ", NS
PRINT #4, "Number of repetitions: ", NR
PRINT #4, "Seed number: ", sd$
PRINT #4, "Log filename: ", lg$
PRINT #4,

REM input data
REM inpu$ is opened and matrix D(i, j) is created

OPEN inpu$ FOR INPUT AS #3
FOR i = 1 TO NS
    FOR j = 1 TO NC
        INPUT #3, D(i, j)
        CLS
        LOCATE 15, 1
        COLOR 14: PRINT "Loading data ......  "; "D("; SPC(0); i; SPC(0); j; SPC(0); ")"
NEXT j, i
CLOSE #3

REM a loop is created. It can be broken only is the digit (stored in y) is "1" or "2"

DO
    CLS
    LOCATE 12, 1
    COLOR 15: INPUT "Resampling with (1 - bootstrap) or without (2) replacement (select 1 or 2)"; y
LOOP UNTIL y = 1 OR y = 2

REM if the digit (stored in y) is "2" the program will go to the "shuffle" routine,
REM otherwise it will proceed to the bootstrap (resampling with replacement)

IF y = 2 THEN GOTO shuffle

REM beginning bootstrap (resampling with replacement)

PRINT #1, "Bootstrap (reampling with replacement)": PRINT #4, "Bootstrap (resampling with replacement)"
PRINT #1,
PRINT #1, "Bootstrap replicate"; CHR$(9); "Sampling event"; CHR$(9); "Accumulation per n. of events"; CHR$(9)
PRINT #2, "Bootstrap (resampling with replacement)"
PRINT #2,
PRINT #2, "Bootstrap replicate"
FOR f = 1 TO NR
    RANDOMIZE  seed    
    FOR j = 1 TO NC
        CLS
        LOCATE 18, 1
        COLOR 14: PRINT "Bootstrapping ......  "; f: PRINT
        PRINT #4,
        PRINT #4, "Bootstrap replicate  "; f: PRINT #4,
        
REM For each bootstrap replicate a random number Q is chosen between 1 and NC (this last is the number of columns in the input matrix)
        
        Q = INT(RND * NC + 1)

REM Then, in a FOR/NEXT cycle, pseudoreplicate data matrix ND(i,j) is constructed using elements that correspond to those in column Q of the input matrix D.
REM Each column of ND(i,j) is printed in the log file along with elements from matrix D, that correspond to column Q.
REM In this way it is possible to verify that elements in matrix nd are exactly the elements from matrix D that correspond to column Q. If they do, the routine is working properly.
REM The pseudoreplicate data matrix ND(i,j)is stored in memory.
REM No such an output is generated if Edition #1 is used

        FOR i = 1 TO NS
            ND(i, j) = D(i, Q)
            PRINT #4, "ND("; SPC(0); i; SPC(0); j; SPC(0); ")="; SPC(0); ND(i, j); CHR$(9); CHR$(9); "D("; SPC(0); i; SPC(0); Q; SPC(0); ")="; SPC(0); D(i, Q); SPC(2)
    NEXT i, j

    REM Then the pseudoreplcated data matrix ND(i,j) is printed in the output file.

    FOR i = 1 TO NS
        PRINT #2,
        PRINT #2, f; CHR$(9);
        FOR j = 1 TO NC
            PRINT #2, ND(i, j); CHR$(9);
    NEXT j, i

    PRINT #4,

REM Starting the acculumation procedure.
REM The "matrix W" (not dimensioned and not stored in memory) is constructed by cumulatively summing elements of the pseudoreplicate data ND(i,j) matrix by row.
REM Matrix W is is only functional to the construction of matrix B(i,j).
REM The matrix B is constructed so that elements > zero in matrix W are set = 1 in matrix B.
REM This stratagem is instrumental to correctly perform accumulation irrespectively whether the input file contains abundance or incidence data.
REM Matrix B is also printed in the log file for quality-checking purposes.

    FOR i = 1 TO NS
        W = 0
        PRINT #4, "Bootstrap replicate  "; f: PRINT #4,
        FOR j = 1 TO NC
            W = W + ND(i, j)
            IF W = 0 THEN B(i, j) = 0 ELSE B(i, j) = 1
            PRINT #4, "W("; SPC(0); i; SPC(0); j; SPC(0); ")="; SPC(0); W; CHR$(9); CHR$(9); "B("; SPC(0); i; SPC(0); j; SPC(0); ")="; SPC(0); B(i, j); SPC(2)
        NEXT j

        PRINT #4,
    NEXT i

REM The accumulation pseudoreplicates are constructed by cumulatively summing elements of matrix B by column.
REM The accumulation pseudoreplicates are not stored in memory, but they are printed in the output file meanwhile they are created.

    C = 0
    FOR j = 1 TO NC
        FOR i = 1 TO NS
            C = C + B(i, j)
            IF i = NS THEN PRINT #1, f; CHR$(9); j; CHR$(9); C; CHR$(9)
            IF i = NS THEN C = 0
    NEXT i, j
    PRINT #2,
NEXT f

REM At the end of the last FOR/NEXT cycle the accumulation file, the pseudoreplicated-dataset file, and the log file are closed.
REM Bootstrap ends and a final message appears on the screen

COLOR 10: PRINT "Completed": PRINT
PRINT "CURSAT ver. 2.1 Edition #2 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
PRINT #1, "CURSAT ver. 2.1 Edition #2 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
PRINT #2, "CURSAT ver. 2.1 Edition #2 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
CLOSE #1: CLOSE #2: CLOSE #4:
COLOR 15: PRINT "Accumulation pseudoreplicates written in "; file$
PRINT "Dataset pseudoreplicates written in "; boot$
END

REM shuffle routine

shuffle:

REM begin resampling without replacement

PRINT #1, "Resampling without replacement": PRINT #4, "Resampling without replacement"
PRINT #1,
PRINT #1, "Replicate"; CHR$(9); "Sampling event"; CHR$(9); "Accumulation per n. of events"; CHR$(9)
PRINT #2, "Resampling without replacement"
PRINT #2,
PRINT #2, "Replicate"

DIM F(NC) AS INTEGER

FOR f = 1 TO NR
    CLS
    LOCATE 18, 1
    COLOR 14: PRINT "Resampling without replacement......  "; f: PRINT
    REDIM F(NC) AS INTEGER
    PRINT #4,

    FOR j = 1 TO NC

REM For each replicate a "Randomnumber" routine is started within which a number Q between 1 and NC (this last is the number of columns in the input matrix)is randomly chosen.
REM The "RANDOMIZE seed" statement just continues the sequence within the FOR/NEXT cycle.
REM The alternative statement "RANDOMIZE USING seed" must not be used. In fact, "USING" resets a seed number sequence to the start of the sequence
REM as if the program just started using that seed. This would inefficiently prolong the duration of the shuffling

        Q = 0
        
REM the "RANDOMIZE seed" instruction is here inside the FOR j = 1 TO NC/NEXT j cycle to prevent the first 256 columns of the first shuffled pseudomatrix to be identical to those in the first bootstrapped matrix obtained with the same seed number.
REM In this way, only the first column in the first bootstrapped and shuffled matrices will be identical, in case the same seed is used.

        RANDOMIZE seed

        Randomnumber:
        Q = INT(RND * NC + 1)

REM A FOR/NEXT cycle during which the number if Q is found in the array, that is if Q = F(y), then the "Randomnumber" routine starts over again.

        FOR y = 1 TO NC
            IF Q = F(y) THEN GOTO Randomnumber
        NEXT y

REM the shuffled order is stored in vector F(j), stored in memory and printed in the log file.

        F(j) = Q
        PRINT #4, F(j);
    NEXT j

    PRINT #4, "-> Shuffling order in this replicate (vector F)"

REM Then, in a FOR/NEXT cycle, pseudoreplicated data matrix ND(i,j) is constructed using elements that correspond to those in column F(j) of the input matrix D.
REM Each column of ND(i,j) is printed in the log file along with elements from matrix D, that correspond to column F(j).
REM In this way it is possible to verify that elements in matrix nd are exactly the elements from matrix D that correspond to column f(j). If they do, the routine is working properly.
REM The pseudoreplicate data matrix nd(i,j)is constructed and stored in memory.
REM No such an output is generated if Edition #1 is used

    FOR j = 1 TO NC
        PRINT #4,: PRINT #4, "Replicate  "; f: PRINT #4,
        FOR i = 1 TO NS
            ND(i, j) = D(i, F(j))
            PRINT #4, "ND("; SPC(0); i; SPC(0); j; SPC(0); ")="; SPC(0); ND(i, j); CHR$(9); CHR$(9); "D("; SPC(0); i; SPC(0); F(j); SPC(0); ")="; SPC(0); D(i, F(j)); SPC(2)

    NEXT i, j

REM Then the pseudoreplcated data matrix ND(i,j) is printed in the output file.

    FOR i = 1 TO NS
        PRINT #2,
        PRINT #2, f; CHR$(9);
        FOR j = 1 TO NC
            PRINT #2, ND(i, j); CHR$(9);
    NEXT j, i

    PRINT #4,

REM Starting the acculumation procedure.
REM The "matrix W" (not dimensioned and not stored in memory) is constructed by cumulatively summing elements of the pseudoreplicate data ND(i,j)
REM Matrix W is is only functional to the construction of matrix B(i,j).
REM Matrix W is printed in the log file for quality-checking purposes.
REM The matrix B is constructed so that elements > zero in matrix W are set = 1 in matrix B.
REM This stratagem is instrumental to correctly perform accumulation irrespectively whether the input file contains abundance or incidence data.
REM Matrix B is also printed in the log file for quality-checking purposes.

    FOR i = 1 TO NS
        W = 0
        PRINT #4, "Replicate  "; f: PRINT #4,
        FOR j = 1 TO NC
            W = W + ND(i, j)
            IF W = 0 THEN B(i, j) = 0 ELSE B(i, j) = 1
            PRINT #4, "W("; SPC(0); i; SPC(0); j; SPC(0); ")="; SPC(0); W; CHR$(9); CHR$(9); "B("; SPC(0); i; SPC(0); j; SPC(0); ")="; SPC(0); B(i, j); SPC(2)
        NEXT j

        PRINT #4,

    NEXT i

REM The accumulation pseudoreplicates are constructed by cumulatively summing elements of matrix B by column.
REM The accumulation pseudoreplicates are not stored in memory, but they are printed in the output file meanwhile they are created.

    C = 0
    FOR j = 1 TO NC
        FOR i = 1 TO NS
            C = C + B(i, j)
            IF i = NS THEN PRINT #1, f; CHR$(9); j; CHR$(9); C; CHR$(9)
            IF i = NS THEN C = 0
    NEXT i, j
    PRINT #2,
NEXT f

REM at the end of the last FOR/NEXT cycle the accumulation-pseudoreplicates,  the dataset-pseudoreplicates, and log files are closed.
REM Shuffling ends and a final message appears on the screen

COLOR 10: PRINT "Completed": PRINT
PRINT "CURSAT ver. 2.1 Edition #2 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
PRINT #1, "CURSAT ver. 2.1 Edition #2 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
PRINT #2, "CURSAT ver. 2.1 Edition #2 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
PRINT #4, "CURSAT ver. 2.1 Edition #2 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
CLOSE #1: CLOSE #2: CLOSE #4:
COLOR 15: PRINT "Accumulation pseudoreplicates written in "; file$
PRINT "Dataset pseudoreplicates written in "; boot$
END
