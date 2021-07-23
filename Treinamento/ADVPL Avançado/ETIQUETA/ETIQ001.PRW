#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

User Function MyFunction()
//https://tdn.totvs.com/display/tec/TFont%3ANew
Private oArial30  	:=	TFont():New("Arial",,30,,.F.,,,,,.F.,.F.)

//Instacia a Classe FWMSPrinter
//https://tdn.totvs.com/display/public/PROT/FWMsPrinter
Private oPrinter  	:=	FWMSPrinter():New("MyFunction")

  //Define orientação de página do relatório como retrato
  oPrinter:SetPortrait()

  //Inicio da pagina
  oPrinter:StartPage()
  //Conteudo  impresso
  printPage()
	//Fim da regra 
  oPrinter:EndPage()

  //Define se será apresentada a visualização do relatório antes da impressão física
  oPrinter:Preview()

Return

Static Function printPage()

  //Escreve na pagina
  oPrinter:Say(0120,0011,"Codigo: ",oArial30,,0)
  //oPrinter:Box( 130, 10, 600, 900, "-4")

  oPrinter:Line( 130, 10, 130, 900,)

 //Escreve na pagina
  oPrinter:Say(0122,0562,"ABC",oArial30,,0)
 //Escreve na pagina
  oPrinter:Say(0240,0011,"Descricao:",oArial30,,0)
 //Escreve na pagina
  oPrinter:Say(0242,0557,"produto 1",oArial30,,0)
 //Escreve o codigo de barras na pagina
  oPrinter:Code128B(0445, 0153, "3334443333", 045)


Return
