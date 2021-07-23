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
Class zProduto01

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

EndClass


Method New(cCod,cDesc,cTipo,cUm,cLocal,nPicm,nIpi,cContrat,cLocaliz) Class zProduto01

    //Atribuindo valores nos atributos do objeto instanciado
    ::cCod 		 := cCod
    ::cDesc		 := cDesc
    ::cTipo		 := cTipo
    ::cUm		 := cUm
    ::cLocal	 := cLocal
    ::nPicm		 := nPicm
    ::nIpi		 := nIpi
    ::cContrat	 := cContrat
    ::cLocaliz	 := cLocaliz

Return Self


User Function zCadPd001()

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

    //Instanciando o objeto Atravez da classe Produto
    oProduto := zProduto01():New(cCod,cDesc,cTipo,cUm,cLocal,nPicm,nIpi,cContrat,cLocaliz)
    
    MsgAlert(oProduto:cCod)

Return
