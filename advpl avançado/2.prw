#include "Fileio.ch"
#include "Protheus.ch"
#include "totvs.ch"

User Function ler()
	Local cPath := "C:\Users\treinamento\Desktop\Development\Testfile.txt"
	local nHandle := FCREATE(cPath)
	Local ctxt := ''
	local i

	DbSelectArea('SA1')

	SA1->(DBGOTOP())

	aEstSA1 := SA1->(DBSTRUCT())


	for i := 1 to Len(aEstSA1)
		cTxt += aEstSA1[i][1] + ";"
	next i
	if nHandle = -1
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	else
		WHILE SA1->(!EOF())

			for i := 1 to Len(aEstSA1)
				cTxt += CVALTOCHAR(&("SA1->"+aEstSA1[i][1])) + ";"
			next i
			dbSkip()

			FWrite(nHandle, cTxt )
			FClose(nHandle)

		ENDDO
	endif

	oFile := FWFILEREADER():New(cPath, ';')

	if file("Testfile.txt")
		if (oFile:Open())
			while (oFile:hasLine())
				Conout(oFile:GetLine())
			end
			oFile:Close()
		endif
	endif
Return
