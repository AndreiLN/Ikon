/// This class is a refactored version from Captcha generator originally made by Fabio Gonçalves
/// <br/>This refactored version to do the generation of identicons was made by Andrei Luiz Nenevê
Class Ikon.Processor Extends %RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

Property Data [ MultiDimensional ];

Property Width As %Integer;

Property Height As %Integer;

Property PenColor As %String(TRUNCATE = 1);

ClassMethod New(width As %Integer, height As %Integer, red As %Integer = 255, green As %Integer = 255, blue As %Integer = 255) As Ikon.Processor
{
	Set img = ##class(Ikon.Processor).%New()
	Set img.Width = width,img.Height = height
	For x = 1:1:width{
		For y = 1:1:height{
			Set img.Data(x,y) = $Char(blue,green,red)
		}
	}
	Do img.SetPen(0,0,0)
	Quit img
}

Method SetPen(red As %Integer, green As %Integer, blue As %Integer) As %Status
{
	Set ..PenColor = $Char(blue,green,red)	
	Quit $$$OK
}

Method Plot(x As %Integer, y As %Integer) As %Status
{
	Quit:(x<1||y<1||y>..Height||x>..Width) 1
	Set ..Data(x,y) = ..PenColor
	Quit $$$OK
}

ClassMethod SetBytes(decimal As %Integer, length As %Integer) As %String
{
	Set ret = ""
	For i = 1:1:length{
		Set ret = ret_$Char(decimal#256), decimal = decimal/256
	}
	Quit ret
}

Method WriteBitmap()
{
    Set bfType = "BM",
    	bfSize = 0,
    	bfReserved1 = ..SetBytes(0,2),
    	bfReserved2=..SetBytes(0,2),
    	bfOffsetBits=..SetBytes(54,4),
    	biSize=..SetBytes(40,4),
    	biWidth=..SetBytes(..Width,4),
    	biHeight=..SetBytes(..Height,4),
    	biPlanes=..SetBytes(1,2),
    	biBitCount=..SetBytes(24,2),
    	biCompression=..SetBytes(0,4),
    	biSizeImage=..SetBytes(0,4),
    	biXPelsPerMeter=..SetBytes(0,4),
    	biYPelsPerMeter=..SetBytes(0,4),
    	biColorsUsed=..SetBytes(0,4),
    	biColorsImportant=..SetBytes(0,4),
    	padding=(..Width*3)#4,
    	padding=$s(padding=0:"",1:$e($c(0,0,0),1,4-padding)),
    	sizeimage=((..Width*3)+$l(padding))*..Height,
    	bfSize=..SetBytes(14+40+sizeimage,4),
    	biSizeImage=..SetBytes(sizeimage,4)
	Write bfType_bfSize_bfReserved1_bfReserved2_bfOffsetBits
	Write biSize_biWidth_biHeight_biPlanes_biBitCount_biCompression_biSizeImage_biXPelsPerMeter_biYPelsPerMeter_biColorsUsed_biColorsImportant
	For y = ..Height:-1:1 {
		For x=1:1:..Width {
			Write ..Data(x,y)
		}
		Write padding
	}
}

}

