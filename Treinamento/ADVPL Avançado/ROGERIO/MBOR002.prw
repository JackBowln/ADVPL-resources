#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "TOPCONN.CH"

Static cTitulo := "Alteração de Bordero"

/*

*/
User Function MBOR002()

	Local cMarca	 := GetMark()
	Local lConfirma	 := .F.
	Local oMarkBr	 := Nil
	Local cFilter

	If Pergunte("MBOR002", .T.)

		cFilter := "E1_FILIAL == '" + MV_PAR01 + "' .AND. E1_NUMBOR == '" + MV_PAR02 + "'"

        //Iniciando classe
		oMarkBr := FWMarkBrowse():New()

        //Setando o ALias
		oMarkBr:SetAlias("SE1")

        //Setando Descrição
		oMarkBr:SetDescription(cTitulo)
		
        //Sertando qual campo sera preenchido com mark
        oMarkBr:SetFieldMark("E1_OK")
    
        //Filtro na tela com os paramentro do pergunte
        oMarkBr:SetFilterDefault(cFilter)

        //selecionando o Markall
        oMarkBr:SetAllMark({|| Processa({|| Makall(@oMarkBr)}, "Aguarde...", "Invertendo a marcação dos itens...", .F.) })
		
        //Adicionando Botões na Rotina
		oMarkBr:AddButton("Processar", { || lConfirma := .T.,oMarkBr:GetOwner():End()},,,, .F., 2 )
        oMarkBr:AddButton("Cancela"  , { || lConfirma := .F.,oMarkBr:GetOwner():End()},,,, .F., 2 )
		
        oMarkBr:SetMenuDef("")
		
        oMarkBr:DisableDetails()
		
        oMarkBr:SetIgnoreARotina(.T.)
		
        //Ativando a Tela
        oMarkBr:Activate()

	EndIf

Return aReturn
