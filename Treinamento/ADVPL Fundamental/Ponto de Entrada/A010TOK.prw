


User Function A010TOK()

	Local lRet      := .T.
	Local cUsrAut   := GetMv("MV_USRAUT", .F., "000002")
	Local cTipAut   := GetMv("MV_TPAUT", .F., "PA")
	Local cTipoProd := M->B1_TIPO
	Local cUsrLog   := RetCodUsr()

	//Verifico se Usuario tem permissão
	If !(cUsrLog $ cUsrAut)
		lRet := .F.
		MsgStop("Usuario não Autorizado!")
	EndIf

	If lRet
		If !(cTipoProd $ cTipAut)
			lRet := .F.
			MsgStop("Tipo de Produto não Autorizado!")
		EndIf
	EndIf

Return lRet













