#INCLUDE "PROTHEUS.CH
#INCLUDE "TOTVS.CH

User Function ENVFTP(cEndereco, nPorta, cUsr, cPass, cArq)
    Local aArea   := GetArea()
    Local lRet    := .T.
    Local cDirAbs := GetSrvProfString("STARTPATH","")  
	
	Default cEndereco := "localhost"
	Default nPorta := 21
	Default cUsr := "sa"
	Default cPass := "sa"
	Default cArq := "grparametro.dtc"

    cDirAbs       += "\" + cArq
     
    //Se conseguir conectar
    If FTPConnect(cEndereco ,nPorta ,cUsr , cPass )
         
        //Desativa o firewall
        FTPSetPasv(.F.)        
         
        //Se não conseguir dar o upload
        If !FTPUpload(cDirAbs, cArq)
            //Realiza mais uma tentativa
            If !FTPUpload(cDirAbs, cArq)
                lRet:=.F.
            EndIf
        EndIf
         
        //Desconecta do FTP
        FTPDisconnect()
    EndIf
 
    RestArea(aArea)
Return lRet
