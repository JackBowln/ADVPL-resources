#include "protheus.ch"
#include "rwmake.ch"

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:

DESC:   Gerando arquivo Texto - Cadastro de Cliente

AUTOR:
*/
User Function GTXTCLI()

    Local aArea := GetArea()

	If MsgYesNo("Deseja Exportar Dados do Cliente?")

        GeraTXT()
	
    EndIf

    RestArea(aArea)

Return


Static Function GeraTXT()

    //Cria o arquivo texto
	Local cArqTxt   := "\SA1\CADASTRO_de_CLIENTE.TXT"
	Local nHdl	    := fCreate(cArqTxt)

	If nHdl == -1
		MsgAlert("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os Parâmetros.","Atenção!")
		Return
	Endif

	//Inicializa o processamento processamento
	RunCont(nHdl)

	MsgInfo("Arquivo Exportado com sucesso!!!")

Return Nil

Static Function RunCont(nHdl)

	Local cLinha
	
    DbSelectArea("SA1")
	SA1->(DbGoTop())

	While !SA1->(Eof())

		cLinha := AllTrim(SA1->A1_COD)    + ";"
		cLinha += AllTrim(SA1->A1_LOJA)   + ";"
		cLinha += AllTrim(SA1->A1_NOME)   + ";"
		cLinha += AllTrim(SA1->A1_NREDUZ) + ";"
		cLinha += AllTrim(SA1->A1_TIPO)   + ";"
		cLinha += AllTrim(SA1->A1_END)    + ";"
		cLinha += AllTrim(SA1->A1_BAIRRO) + ";"
		cLinha += AllTrim(SA1->A1_EST)    + ";"
		cLinha += AllTrim(SA1->A1_MUN)    + CRLF

        //Iniciar a Gravação no Arquivo .txt
		If fWrite(nHdl,cLinha,Len(cLinha)) != Len(cLinha)
            
            MsgAlert("O Disco Rígido está Cheio ou Ocorreu Erro na Gravação do Arquivo.")
            Return .F.

		Endif

		SA1->(DbSkip())
	EndDo

    //O arquivo texto deve ser fechado
	fClose(nHdl)

Return .T.
