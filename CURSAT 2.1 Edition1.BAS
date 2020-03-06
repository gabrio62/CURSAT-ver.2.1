REM Display of the initial screen
DIM NC AS INTEGER
DIM NS AS INTEGER
DIM NR AS INTEGER
DIM Q AS INTEGER
CLS
CLEAR
COLOR 15: PRINT "CURSAT  ver 2.1  Edition #1 - A simple, resampling-based, program to generate"
PRINT "pseudoreplicates of data and calculate rarefaction curves": PRINT
PRINT "Gabriele Gentile, Department of Biology, University TOR VERGATA"
PRINT "Via della Ricerca Scientifica, 1 - 00133, Rome, Italy"
PRINT "E-mail: gabriele.gentile@uniroma2.it"
PRINT: PRINT

COLOR 10: PRINT "License statement: "; SPC(0): COLOR 15: PRINT "This software may be used and distributed as regulated by the MIT License"

REM Copyright <2020>abriele Gentile>
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
PRINT

REM  input of number of repetitions, seed number, and filenames
REM  Dimensioning input data matrix D(NS, NC), pseudomatrix ND(NS,NC), and "incidence" matrix B(NS,NC)

INPUT "How many columns (sampling events)"; NC
INPUT "How many rows (species, OTUs, objects,...)"; NS
INPUT "How many repetitions"; NR
INPUT "Seed number"; sd$: seed = VAL(sd$)
DIM D(NS, NC), ND(NS, NC), B(NS, NC)

INPUT "Input filename"; inpu$
INPUT "Accumulation pseudoreplicates' filename"; file$
INPUT "Dataset pseudoreplicates' filename"; boot$
CLS

REM Opening files for accumulation-pseudoreplicates (file$) and for dataset-pseudoreplicates (boot$) output files

OPEN file$ FOR OUTPUT AS #1
OPEN boot$ FOR OUTPUT AS #2

BEGINTIME$ = TIME$

REM Printing to accumulation-pseudoreplicates (file$) output file

PRINT #1, "CURSAT ver 2.1 Edition #1 ", "Date: ", DATE$, "  Hour: ", BEGINTIME$
PRINT #1, "Input file:  ", inpu$
PRINT #1, "Accumulation pseudoreplicates' file: ", file$
PRINT #1, "Dataset pseudoreplicates' file: ", boot$
PRINT #1, "Number of columns (sampling events): ", NC
PRINT #1, "Number of rows (species, OTUs, ojects,...): ", NS
PRINT #1, "Number of repetitions: ", NR
PRINT #1, "Seed number: ", sd$
PRINT #1,

REM Printing to dataset-pseudoreplicates (boot$) output file

PRINT #2, "CURSAT ver 2.1 Edition #1 ", "Date: ", DATE$, "  Hour: ", BEGINTIME$
PRINT #2, "Input file:  ", inpu$
PRINT #2, "Accumulation pseudoreplicates' file: ", file$
PRINT #2, "Dataset pseudoreplicates' file: ", boot$
PRINT #2, "Number of columns (sampling events): ", NC
PRINT #2, "Number of rows (species, OTUs, objects,...): ", NS
PRINT #2, "Number of repetitions: ", NR
PRINT #2, "Seed number: ", sd$
PRINT #2,

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

PRINT #1, "Bootstrap (resampling with replacement)"
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
        
REM For each bootstrap replicate a random number Q between 1 and NC (this last is the number of columns in the input matrix)

        Q = INT(RND * NC + 1)
        
REM Then, in a FOR/NEXT cycle, pseudoreplicate data matrix ND(i,j) is constructed using elements that correspond to those in column Q of the input matrix D.
REM The pseudoreplicate data matrix ND(i,j)is stored in memory.

        FOR i = 1 TO NS
            ND(i, j) = D(i, Q)
    NEXT i, j
    
REM Then the pseudoreplcated data matrix ND(i,j) is printed in the output file.

    FOR i = 1 TO NS
        PRINT #2,
        PRINT #2, f; CHR$(9);
        FOR j = 1 TO NC
            PRINT #2, ND(i, j); CHR$(9);
    NEXT j, i

 REM Starting the acculumation procedure.
 REM The "matrix W" (not dimensioned and not stored in memory) is constructed by cumulatively summing elements of the pseudoreplicate data ND(i,j) matrix by row.
 REM Matrix W is is only functional to the construction of matrix B(i,j).
 REM The matrix B is constructed so that elements > zero in matrix W are set = 1 in matrix B.
 REM This stratagem is instrumental to correctly perform accumulation irrespectively whether the input file contains abundance or incidence data.

    FOR i = 1 TO NS
        W = 0
        FOR j = 1 TO NC
            W = W + ND(i, j)
            IF W = 0 THEN B(i, j) = 0 ELSE B(i, j) = 1
        NEXT j
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

REM At the end of the last FOR/NEXT cycle the accumulation file and the pseudoreplicated-dataset file are closed.
REM Bootstrap ends and a final message appears on the screen

COLOR 10: PRINT "Completed": PRINT
PRINT "CURSAT ver. 2.1 Edition #1 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
PRINT #1, "CURSAT ver. 2.1 Edition #1 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
PRINT #2, "CURSAT ver. 2.1 Edition #1 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
CLOSE #1: CLOSE #2
COLOR 15: PRINT "Accumulation pseudoreplicates written in "; file$
PRINT "Dataset pseudoreplicates written in "; boot$
END

REM shuffle routine

shuffle:

REM begin resampling without replacement

PRINT #1, "Resampling without replacement"
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

    FOR j = 1 TO NC

REM For each replicate a "Randomnumber" routine is started within which a number Q between 1 and NC (this last is the number of columns in the input matrix)is randomly chosen.
REM The "RANDOMIZE seed" statement just continues the sequence within the FOR/NEXT cycle.
REM The alternative statement "RANDOMIZE USING seed" must not be used. In fact, "USING" resets a seed number sequence to the start of the sequence
REM as if the program just started using that seed. This would inefficiently prolong the duration of the shuffling

        Q = 0
        
REM the "RANDOMIZE seed" instruction is here inside the FOR j = 1 TO NC/NEXT j cycle to prevent the first 256 numbers of the first shuffled pseudomatrix to be identical to those in the first bootstrapped matrix obtained with the same seed number.
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
    NEXT j

REM Then, in a FOR/NEXT cycle, pseudoreplicated data matrix ND(i,j) is constructed using elements that correspond to those in column F(j) of the input matrix D.
REM The pseudoreplicate data matrix ND(i,j)is constructed and stored in memory.

    FOR j = 1 TO NC
        FOR i = 1 TO NS
            ND(i, j) = D(i, F(j))
    NEXT i, j

REM Then the pseudoreplcated data matrix ND(i,j) is printed in the output file.

    FOR i = 1 TO NS
        PRINT #2,
        PRINT #2, f; CHR$(9);
        FOR j = 1 TO NC
            PRINT #2, ND(i, j); CHR$(9);
    NEXT j, i

REM Starting the acculumation procedure.
REM The "matrix W" (not dimensioned and not stored in memory) is constructed by cumulatively summing elements of the pseudoreplicate data ND(i,j) 
REM Matrix W is is only functional to the construction of matrix B(i,j).
REM The matrix B is constructed so that elements > zero in matrix W are set = 1 in matrix B.
REM This stratagem is instrumental to correctly perform accumulation irrespectively whether the input file contains abundance or incidence data.

    FOR i = 1 TO NS
        W = 0
        FOR j = 1 TO NC
            W = W + ND(i, j)
            IF W = 0 THEN B(i, j) = 0 ELSE B(i, j) = 1
        NEXT j
        W = 0
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


REM at the end of the last FOR/NEXT cycle the accumulation-pseudoreplicates and the dataset-pseudoreplicates files are closed.
REM Shuffling ends and a final message appears on the screen

COLOR 10: PRINT "Completed": PRINT
PRINT "CURSAT ver. 2.1 Edition #1 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
PRINT #1, "CURSAT ver. 2.1 Edition #1 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
PRINT #2, "CURSAT ver. 2.1 Edition #1 started on "; SPC(0); DATE$; SPC(1); "at "; SPC(0); BEGINTIME$; SPC(1); "and ended on "; SPC(0); DATE$; SPC(1); "at "; TIME$: PRINT
CLOSE #1: CLOSE #2
COLOR 15: PRINT "Accumulation pseudoreplicates written in "; file$
PRINT "Dataset pseudoreplicates written in "; boot$
END


