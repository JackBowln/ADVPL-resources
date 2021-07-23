
#include 'protheus.ch'
#include 'parmtype.ch'


USER Function CriaP12()

    Local _sAlias	:= Alias() 
    Local aArea	:= GetArea() 
    Local aRegs	:= {}
    Local nI	:= 0 
    Local nJ	:= 0 
    Local nCampo:= 0 
    Local nX	:= 0

    Local cPerg	:= "XGRUP2"

    dbSelectArea("SX1") 
    dbSetOrder(1)

    cPerg := PADR(cPerg,10)

    //   Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt 01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
    // aCampos :=  {"GRUPO","ORDEM","PERGUNT","VARIAVL","TIPO","TAMANHO","DECIMAL","PRESEL","GSC","VAL ID","VAR01","DEF01","CNT01","VAR01","DEF01","CNT01","VAR02","DEF02","CNT02","VAR03","DEF03","CNT03","VAR04","DEF04","CNT04","VAR05","DEF05","CNT05","F3"}
    //https://tdn.totvs.com/pages/viewpage.action?pageId=22479548
    aAdd(aRegs,{cPerg,"01","Grupo de	","","","MV_PAR01" ,"C",TamSX3("B1_GRUPO")[1],0,0,"G","" ,"MV_PAR01","","","","","","","","","","","","","","","SBM"})
    aAdd(aRegs,{cPerg,"02","Grupo ate	","","","MV_PAR02" ,"C",TamSX3("B1_GRUPO")[1],0,0,"G","" ,"MV_PAR02","","","","","","","","","","","","","","","SBM"})
    aAdd(aRegs,{cPerg,"03","DESC	","","","MV_PAR03" ,"C",TamSX3("B1_DESC")[1],0,0,"G","" ,"MV_PAR03","","","","","","","","","","","","","","","SBM"})

    dbSelectArea("SX1")
    dbSetOrder(1)
    For nX:=1 to Len(aRegs)
        If DbSeek( cPerg + aRegs[nx][02] )
            If RecLock('SX1',.F.)
                Replace SX1->X1_GRUPO	 With aRegs[nx][01]
                Replace SX1->X1_ORDEM	 With aRegs[nx][02]
                Replace SX1->X1_PERGUNTE With aRegs[nx][03]
                Replace SX1->X1_PERSPA	With aRegs[nx][04]
                Replace SX1->X1_PERENG	With aRegs[nx][05]
                Replace SX1->X1_VARIAVL	With aRegs[nx][06]
                Replace SX1->X1_TIPO	With aRegs[nx][07]
                Replace SX1->X1_TAMANHO	With aRegs[nx][08]
                Replace SX1->X1_DECIMAL	With aRegs[nx][09]
                Replace SX1->X1_PRESEL	With aRegs[nx][10]
                Replace SX1->X1_GSC		With aRegs[nx][11]
                Replace SX1->X1_VALID	With aRegs[nx][12]
                Replace SX1->X1_VAR01	With aRegs[nx][13]
                Replace SX1->X1_DEF01	With aRegs[nx][14]
                Replace SX1->X1_DEF02	With aRegs[nx][17]
                Replace SX1->X1_DEF03	With aRegs[nx][20]
                Replace SX1->X1_DEF04	With aRegs[nx][23]
                Replace SX1->X1_DEF05	With aRegs[nx][26]
                Replace SX1->X1_F3	    With aRegs[nx][28] 
                SX1->(MsUnlock())
            Else
                Help('',1,'REGNOIS')
            EndIf
        Else
            If RecLock('SX1',.T.)
                Replace SX1->X1_GRUPO		With aRegs[nx][01]
                Replace SX1->X1_ORDEM	With aRegs[nx][02]
                Replace SX1->X1_PERGUNTE With aRegs[nx][03]
                Replace SX1->X1_PERSPA	With aRegs[nx][04]
                Replace SX1->X1_PERENG	With aRegs[nx][05]
                Replace SX1->X1_VARIAVL	With aRegs[nx][06]
                Replace SX1->X1_TIPO	With aRegs[nx][07]
                Replace SX1->X1_TAMANHO	With aRegs[nx][08]
                Replace SX1->X1_DECIMAL	With aRegs[nx][09]
                Replace SX1->X1_PRESEL	With aRegs[nx][10]
                Replace SX1->X1_GSC		With aRegs[nx][11]
                Replace SX1->X1_VALID	With aRegs[nx][12]
                Replace SX1->X1_VAR01	With aRegs[nx][13]
                Replace SX1->X1_DEF01	With aRegs[nx][14]
                Replace SX1->X1_DEF02	With aRegs[nx][17]
                Replace SX1->X1_DEF03	With aRegs[nx][20]
                Replace SX1->X1_DEF04	With aRegs[nx][23]
                Replace SX1->X1_DEF05	With aRegs[nx][26]
                Replace SX1->X1_F3	    With aRegs[nx][28]
                SX1->(MsUnlock())
            Else
                Help('',1,'REGNOIS')
            EndIf
        Endif
    Next nX

    dbSelectArea(_sAlias)
    RestArea(aArea)
Return NIL
