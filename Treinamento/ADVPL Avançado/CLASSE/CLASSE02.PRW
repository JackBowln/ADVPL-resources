//Bibliotecas
#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*
DATA:

DESC:   Criação de Classes em AdvPL

AUTOR:
*/
//https://tdn.totvs.com/pages/viewpage.action?pageId=6063065
Class zProd02

	//Atributos
	Data cCod
	Data cDesc
	Data cTipo
	Data cUm
	Data cLocal
	Data nPicm
	Data nIpi
	Data cContrat
	Data cLocaliz

	Method New() CONSTRUCTOR
	Method Incluir()
	Method Altera()

EndClass


Method New(cCod,cDesc,cTipo,cUm,cLocal,nPicm,nIpi,cContrat,cLocaliz) Class zProd02

	//Atribuindo valores nos atributos do objeto instanciado
	::cCod 	   := cCod
	::cDesc	   := cDesc
	::cTipo	   := cTipo
	::cUm	   := cUm
	::cLocal   := cLocal
	::nPicm	   := nPicm
	::nIpi 	   := nIpi
	::cContrat := cContrat
	::cLocaliz := cLocaliz

Return Self


Method incluir() Class zProd02

	Local cMsg          := ""
	Local aVetor        := {}

	Private lMsErroAuto := .F.

	aVetor:= {;
		{"B1_COD"    ,::cCod     ,NIL},;
		{"B1_DESC"   ,::cDesc    ,NIL},;
		{"B1_TIPO"   ,::cTipo    ,Nil},;
		{"B1_UM"     ,::cUm      ,Nil},;
		{"B1_LOCPAD" ,::cLocal   ,Nil},;
		{"B1_PICM"   ,::nPicm    ,Nil},;
		{"B1_IPI"    ,::nIpi     ,Nil},;
		{"B1_CONTRAT",::cContrat ,Nil},;
		{"B1_LOCALIZ",::cLocaliz ,Nil}}

	MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)

	If lMsErroAuto
		MostraErro()
	Else
		cMsg := "Cadastro efetuado. Produto : " + ::cCod
	Endif

Return {lMsErroAuto,cMsg}


//=======================
//Alteração de Produto  =
//=======================
Method Altera() Class zProd02

	Local cMsg   := ""
	Local aVetor := {}

	Private lMsErroAuto := .F.

	aVetor:= {;
		{"B1_COD"    ,::cCod     ,NIL},;
		{"B1_DESC"   ,::cDesc    ,NIL},;
		{"B1_TIPO"   ,::cTipo    ,Nil},;
		{"B1_UM"     ,::cUm      ,Nil},;
		{"B1_LOCPAD" ,::cLocal   ,Nil},;
		{"B1_PICM"   ,::nPicm    ,Nil},;
		{"B1_IPI"    ,::nIpi     ,Nil},;
		{"B1_CONTRAT",::cContrat ,Nil},;
		{"B1_LOCALIZ",::cLocaliz ,Nil}}

	MSExecAuto({|x,y| Mata010(x,y)},aVetor,4)

	If lMsErroAuto
		MostraErro()
	Else
		cMsg := "Cadastro Alterado. Produto : " + ::cCod
	Endif

Return


//===============================================
//Função ADVPL para Iniciar a Chamada da Classe =   
//===============================================
User Function zCadPd02()

	Local cCod 	   := '9994'
	Local cDesc	   := 'PRODUTO TESTE - ROTINA AUTOMATICA'
	Local cTipo	   := 'PA'
	Local cUm	   := 'UN'
	Local cLocal   := '01'
	Local nPicm	   := 0
	Local nIpi	   := 0
	Local cContrat := 'N'
	Local cLocaliz := 'N'
	Local oProduto
	Local oProduto2
	Local aRet

	//Instanciando o objeto através da classe Produto
	oProduto := zProd02():New(cCod,cDesc,cTipo,cUm,cLocal,nPicm,nIpi,cContrat,cLocaliz)

	//Chamando um método da classe
	oProduto:incluir()

Return
