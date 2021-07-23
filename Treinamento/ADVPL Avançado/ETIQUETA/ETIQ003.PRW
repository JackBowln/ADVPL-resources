#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

//-------------------------------------------------------------------
/*/ { Protheus.doc } GROR021
Impressão de Etiqueta

@author Kenny Roger Martins
@since 11/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------

User Function ETIQ003(lManual, lDisableSetup)
	
	Local cSql      := ""
	Local qQuery    := ""	
	Local cPergunte := Padr("GROR021",10)	
	
	Default lManual       := .T.
	Default lDisableSetup := .F.

	AtuSx1(cPergunte)

	If Pergunte(cPergunte, lManual)
	
		lManual := .F.
		
	EndIf

	If !lManual

		cSql := "     SELECT top 1 * from SB1990" + CHR(10)
		/*
		cSql := "     SELECT * " + CHR(10)
		cSql += "       FROM " + RETSQLNAME("SB8") + " SB8 " + CHR(10)
		cSql += "  LEFT JOIN " + RETSQLNAME("ZG3") + " ZG3 " + CHR(10)
		cSql += "         ON ZG3.ZG3_FILIAL = '" + xFilial("ZG3") + "' " + CHR(10)	
		cSql += "        AND ZG3.ZG3_CODIGO = SB8.B8_YCAVALE " + CHR(10)	
		cSql += "        AND ZG3.D_E_L_E_T_ = '' " + CHR(10) 
		cSql += "  LEFT JOIN " + RETSQLNAME("ZG4") + " ZG4 " + CHR(10)
		cSql += "         ON ZG4.ZG4_FILIAL = '" + xFilial("ZG4") + "' " + CHR(10)	
		cSql += "        AND ZG4.ZG4_CODIGO = SB8.B8_YCLASSI " + CHR(10)	
		cSql += "        AND ZG4.D_E_L_E_T_ = '' " + CHR(10) 
		cSql += " INNER JOIN " + RETSQLNAME("SB1") + " SB1 " + CHR(10)
		cSql += "         ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' " + CHR(10)	
		cSql += "        AND SB1.B1_COD     = SB8.B8_PRODUTO " + CHR(10)	
		cSql += "        AND SB1.D_E_L_E_T_ = '' " + CHR(10) 
		cSql += " INNER JOIN " + RETSQLNAME("SBM") + " SBM " + CHR(10)
		cSql += "         ON SBM.BM_FILIAL  = '" + xFilial("SBM") + "' " + CHR(10)	
		cSql += "        AND SBM.BM_GRUPO   = SB1.B1_GRUPO " + CHR(10)	
		cSql += "        AND SBM.BM_YTIPO   IN ('C','L') " + CHR(10)			
		cSql += "        AND SBM.D_E_L_E_T_ = '' " + CHR(10) 
		cSql += " INNER JOIN " + RETSQLNAME("SB5") + " SB5 " + CHR(10)
		cSql += "         ON SB5.B5_FILIAL  = '" + xFilial("SB5") + "' " + CHR(10)	
		cSql += "        AND SB5.B5_COD     = SB8.B8_PRODUTO " + CHR(10)		
		cSql += "        AND SB5.D_E_L_E_T_ = '' " + CHR(10) 
		cSql += "      WHERE SB8.B8_FILIAL  = '" + xFilial("SB8") + "' " + CHR(10)
		cSql += "        AND SB8.B8_PRODUTO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CHR(10) 
		cSql += "        AND SB8.B8_LOTECTL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + CHR(10) 
		cSql += "        AND SB8.B8_NUMLOTE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CHR(10) 
		cSql += "        AND SB8.B8_YCAVALE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " + CHR(10) 
		cSql += "        AND SB8.B8_SALDO   > 0 " + CHR(10) 		
		cSql += "        AND SB8.D_E_L_E_T_ = '' " + CHR(10) 
		*/
		TCQUERY cSQL NEW ALIAS qQUERY
	
		MsAguarde({|| setEtiqueta(qQUERY, lDisableSetup) },"Impressão de etiqueta...","Aguarde...")
	
		qQUERY->(DbCloseArea())	

	EndIf
			
Return Nil


Static Function setEtiqueta(qQUERY, lDisableSetup)

	Local cCodBar   := ""
	Local cLote     := ""
	Local cDescpro  := ""
	Local cMedida   := ""
    Local cClassi   := ""
    Local cCavalete := ""
    Local cPesoLiq  := "0,000"
    Local cPesoBru  := "0,000"
    Local nSeg      := 0 
    Local cCodigo   := ""
   

	Local nQuant	:= 1
	Local cImpress  := "" //"PDFCreator"
	Local cModBarr  := AllTrim(GetNewPar("GR_MODBARR", "CODE128"))                                   
	Local cLogo 	:= "logo.bmp"
	Local cMatriz   := "matriz.bmp"
	Local oFont06	:= TFont():New('Consolas',,06,,.F.,,,,.T.,.F.,.F.)
	Local oFont06N	:= TFont():New('Consolas',,06,,.T.,,,,.T.,.F.,.F.)
	Local oFont08	:= TFont():New('Consolas',,08,,.F.,,,,.T.,.F.,.F.)
	Local oFont08N	:= TFont():New('Consolas',,08,,.T.,,,,.T.,.F.,.F.)
	Local oFont10	:= TFont():New('Consolas',,10,,.F.,,,,.T.,.F.,.F.)
	Local oFont10N	:= TFont():New('Consolas',,10,,.T.,,,,.T.,.F.,.F.)
	Local oFont12	:= TFont():New('Consolas',,12,,.F.,,,,.T.,.F.,.F.)
	Local oFont12N	:= TFont():New('Consolas',,12,,.T.,,,,.T.,.F.,.F.)
	Local oFont14N	:= TFont():New('Consolas',,14,,.T.,,,,.T.,.F.,.F.)
	Local cCodAuto  := GetNewPar("GR_CODAUTO", "")	
	Local  i := 0 

	Local lAdjustToLegacy := .F.

	Default lDisableSetup := .F.

	MsProcTxt("Iniciando impressão...")

	Private oPrinter := FWMSPrinter():New("produto"+Alltrim(__cUserID)+".etq", IMP_SPOOL, lAdjustToLegacy, "/spool/", lDisableSetup,,, Alltrim(cImpress))

	oPrinter:SetMargin(001,001,001,001)
		
	//While qQUERY->(!(EOF()))
	FOR i:= 1 to 3
	
		/*
		If Empty(cCodAuto)
	
			cCodBar  := U_GETCODBAR(qQUERY->B5_YTIPMAT, qQUERY->B8_LOTECTL, qQUERY->B8_NUMLOTE)

		Else

			If Empty(qQUERY->(B8_YCODBAR))
			
				cCodBar  := &(cCodAuto)

				SB8->(DbGoTo(qQUERY->(R_E_C_N_O_)))
				
				RecLock("SB8", .F.)
				SB8->B8_YCODBAR := cCodBar
				SB8->(MsUnLock())

				ConfirmSX8()

			Else

				cCodBar := qQUERY->(B8_YCODBAR)

			EndIf

		EndIf
		*/
        cCodigo := "000099"
		cCodBar := "00003661001"
		cLote     := "00003661" //AllTrim(qQUERY->B8_LOTECTL)
        cSublote  := "001" //AllTrim(qQUERY->B8_NUMLOTE)
		cDescPro  := "CHAPA GRANITO PRETO METEORUS 2,0 CM BRUTO" //AllTrim(qQUERY->B1_DESC)
		cMedida   := "2,88 X 1,79"//AllTrim(Transform(qQUERY->B8_YCOMLIQ, "@E 999.99")) + " X " + AllTrim(Transform(qQUERY->B8_YALTLIQ, "@E 999.99"))
        cTotal    := "5,16" // AllTrim(Transform(qQUERY->B8_YCOMLIQ * qQUERY->B8_YALTLIQ, "@E 999.99"))
        cClassi   := "2 - COMERCIAL" //AllTrim(qQUERY->ZG4_DESCRI)        
        cCavalete := ""  //AllTrim(qQUERY->B8_YCAVALE)
        cPesoLiq  := "0,000" //AllTrim(Transform(qQUERY->ZG3_PESOLQ, "@E 9,999,999.999"))
        cPesoBru  := "0,000" //AllTrim(Transform(qQUERY->ZG3_PESOBR, "@E 9,999,999.999"))
        
		MsProcTxt("Imprimindo etiqueta " + cCodBar + "...")

		oPrinter:StartPage()

        // Primeira Etiqueta
		oPrinter:Code128B(035, 030, cCodBar, 022)
		oPrinter:Say(043, 040, cCodBar, oFont08N)

		oPrinter:Say(075, 140, SubStr(cDescPro,1,60), oFont08N,,,90)

		oPrinter:Say(075, 130, "BLOCO(LOTE): " + cLote, oFont08N,,,90)
		oPrinter:Say(210, 130, "CHAPA(SUBLOTE): " + cSublote, oFont08N,,,90)

		oPrinter:Say(075, 120, "MEDIDA LÍQUIDA: " + cMedida, oFont08N,,,90)
		oPrinter:Say(220, 120, "TOTAL: " + cTotal + " M²", oFont08N,,,90)

		oPrinter:Say(075, 110, "CLASSIFICAÇÃO COMERCIAL: " + cClassi, oFont08N,,,90)

		oPrinter:Say(075, 100, "CAVALETE: " + cCavalete,  oFont08N,,,90)

		oPrinter:Say(075, 090, "PESO LIQ: " + cPesoLiq, oFont08N,,,90)
		oPrinter:Say(195, 090, "PESO BRU: " + cPesoBru, oFont08N,,,90)

		oPrinter:Say(075, 080, "DATA: " + DTOC(dDataBase), oFont08N,,,90)
		oPrinter:Say(165, 080, "HORA: " + SUBSTR(TIME(),1,5), oFont08N,,,90)

		oPrinter:Say(075, 070, "OPERADOR: " + cUsername, oFont08N,,,90)

		oPrinter:SayBitmap(075, 020, cLogo,   30, 080)
		oPrinter:SayBitmap(200, 020, cMatriz, 60, 110)

        // Segunda Etiqueta
        nSeg := 250

		oPrinter:Say(075+nSeg, 140, SubStr(cDescPro,1,60), oFont08N,,,90)

		oPrinter:Say(075+nSeg, 130, "BLOCO(LOTE): " + cLote, oFont08N,,,90)
		oPrinter:Say(210+nSeg, 130, "CHAPA(SUBLOTE): " + cSublote, oFont08N,,,90)

		oPrinter:Say(075+nSeg, 120, "MEDIDA LÍQUIDA: " + cMedida, oFont08N,,,90)
		oPrinter:Say(220+nSeg, 120, "TOTAL: " + cTotal + " M²", oFont08N,,,90)

		oPrinter:Say(075+nSeg, 110, "CLASSIFICAÇÃO COMERCIAL: " + cClassi, oFont08N,,,90)

		oPrinter:Say(075+nSeg, 100, "CAVALETE: " + cCavalete,  oFont08N,,,90)

		oPrinter:Say(075+nSeg, 090, "PESO LIQ: " + cPesoLiq, oFont08N,,,90)
		oPrinter:Say(195+nSeg, 090, "PESO BRU: " + cPesoBru, oFont08N,,,90)

		oPrinter:Say(075+nSeg, 080, "DATA: " + DTOC(dDataBase), oFont08N,,,90)
		oPrinter:Say(165+nSeg, 080, "HORA: " + SUBSTR(TIME(),1,5), oFont08N,,,90)

		oPrinter:Say(075+nSeg, 070, "OPERADOR: " + cUsername, oFont08N,,,90)

		oPrinter:SayBitmap(075+nSeg, 020, cLogo,   30, 080)
		oPrinter:SayBitmap(200+nSeg, 020, cMatriz, 60, 110)
        
		oPrinter:Code128B(602, 030, cCodBar, 022)
		oPrinter:Say(610, 040, cCodBar, oFont08N)

		oPrinter:EndPage()
					
		//qQUERY->(DbSkip())
	Next
	//EndDo
		
	oPrinter:Preview()
	//oPrinter:Print()

Return Nil

/*---------+----------+-------+-----------------------+------+------------+
|Função    |AtuSx1    | Autor |KENNY ROGER MARTINS    | Data | 27.04.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria perguntas                                                |
+----------+--------------------------------------------------------------+
|Uso       |Gestão de Rochas Ornamentais                                  |
+----------+-------------------------------------------------------------*/
Static Function AtuSx1(cPerg)

	Local aDados := {}
	
	aAdd( aDados, {cPerg,'01','Material De ?',        '','','MV_CH0','C',15,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','SB1','','','','',''} )
	aAdd( aDados, {cPerg,'02','Material Até ?',       '','','MV_CH0','C',15,0,0,'G','','MV_PAR02','','','','ZZZZZZZZZZZZZZZ','','','','','','','','','','','','','','','','','','','','','SB1','','','','',''} )
	aAdd( aDados, {cPerg,'03','Lote De ?',            '','','MV_CH0','C',10,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
	aAdd( aDados, {cPerg,'04','Lote Ate ?',           '','','MV_CH0','C',10,0,0,'G','','MV_PAR04','','','','ZZZZZZZZZZ','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
	aAdd( aDados, {cPerg,'05','SubLote De ?',         '','','MV_CH0','C',06,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
	aAdd( aDados, {cPerg,'06','SubLote Ate ?',        '','','MV_CH0','C',06,0,0,'G','','MV_PAR06','','','','ZZZZZZ','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
	aAdd( aDados, {cPerg,'07','Cavalete De ?',        '','','MV_CH0','C',06,0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
	aAdd( aDados, {cPerg,'08','Cavalete Ate ?',       '','','MV_CH0','C',06,0,0,'G','','MV_PAR08','','','','ZZZZZZ','','','','','','','','','','','','','','','','','','','','','','','','','',''} )

	AtuSx11(aDados)	

Return Nil



//Cria pergunte na SX1

STATIC Function AtuSX11(aDados)
Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local nI       := 0
Local nJ       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )

Default aDados := {}

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

//
// Atualizando dicionário
//
dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aDados )
	If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

RestArea( aAreaDic )
RestArea( aArea )

Return NIL
