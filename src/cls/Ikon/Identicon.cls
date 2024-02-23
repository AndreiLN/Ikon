/// <b>Identicon Generator in COS</b><br/>
/// Author: Andrei Luiz Nenevê - alneneve@gmail.com<br/>
/// Requires: Caché 2016.2 or Newer<br/><br/>
/// Example:<br/>
/// <example>
/// ; Parameters=> Word, Directory, Size, Background amount of red, green, blue
/// Do ##class(Ikon.Identicon).%New("test","C:\Identicons\",250,255,255,155)
/// </example>
Class Ikon.Identicon Extends %RegisteredObject
{

Property Name As %String;

Property Hash As %DynamicArray;

Property Color As %DynamicArray;

Property Grid As %DynamicArray;

Property GridPoint As %DynamicArray;

Property PixelMap As %DynamicArray;

Property Directory As %String [ InitialExpression = "C:\Identicons\" ];

Property FileFullName As %String;

Property Size As %Integer [ InitialExpression = 250 ];

Property BackgroundColor As %String [ InitialExpression = "255,255,255" ];

Method HashInput() As %Status [ Private ]
{
	Set tSC = $$$OK
	Try {
		Set identicon  = ##class(%SYSTEM.Encryption).MD5Hash(..Name)
		Set ..Hash = ##class(%DynamicArray).%New()
		For i=1:1:$Length(identicon){
			$$$THROWONERROR(tSC, ..Hash.%Push($ASCII($Extract(identicon,i))))
		}
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method PickColor() As %Status [ Private ]
{
	Set tSC = $$$OK
	Try {
		Set ..Color = ##class(%DynamicArray).%New()
		$$$THROWONERROR(tSC, ..Color.%Push(..Hash.%Get(0))) //Red
		$$$THROWONERROR(tSC, ..Color.%Push(..Hash.%Get(1))) //Green
		$$$THROWONERROR(tSC, ..Color.%Push(..Hash.%Get(2))) //Blue
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method BuildGrid() As %Status [ Private ]
{
	Set tSC = $$$OK
	Try {
		Set ..Grid = ##class(%DynamicArray).%New()
		For i=0:3:..Hash.%Size(){
			Quit:(i+3>(..Hash.%Size()-1))
			Set chunk = ##class(%DynamicArray).%New()
			Set fst = ..Hash.%Get(i), sec = ..Hash.%Get(i+1)
			$$$THROWONERROR(tSC, ..Grid.%Push(fst))
			$$$THROWONERROR(tSC, ..Grid.%Push(sec))
			$$$THROWONERROR(tSC, ..Grid.%Push(..Hash.%Get(i+2)))
			$$$THROWONERROR(tSC, ..Grid.%Push(sec))
			$$$THROWONERROR(tSC, ..Grid.%Push(fst))
		}
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method FilterOddSquares() As %Status [ Private ]
{
	Set tSC = $$$OK
	Try {
		Set ..GridPoint = ##class(%DynamicArray).%New()
		Set iter = ..Grid.%GetIterator()
		While iter.%GetNext(.key,.value){
			If value # 2 = 0{
				Set obj = ##class(%DynamicObject).%New()
				Set obj.key = key
				Set obj.value = value
				$$$THROWONERROR(tSC, ..GridPoint.%Push(obj))
			}
		}
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method BuildPixelMap() As %Status [ Private ]
{
	Set tSC = $$$OK
	Try {
		Set ..PixelMap = ##class(%DynamicArray).%New()
		Set iter = ..GridPoint.%GetIterator()
		While iter.%GetNext(.key,.value){
			Set horizontal = (value.key # 5) * (..Size/5)
			Set vertical = (value.key \ 5) * (..Size/5)
			
			Set point = ##class(%DynamicObject).%New()
			
			Set cord = ##class(%DynamicObject).%New()
			$$$THROWONERROR(tSC, cord.%Set("x",horizontal))
			$$$THROWONERROR(tSC, cord.%Set("y",vertical))
			$$$THROWONERROR(tSC, point.%Set("topLeft",cord))
			
			Set cord = ##class(%DynamicObject).%New()
			$$$THROWONERROR(tSC, cord.%Set("x",horizontal+(..Size/5)))
			$$$THROWONERROR(tSC, cord.%Set("y",vertical+(..Size/5)))
			$$$THROWONERROR(tSC, point.%Set("bottomRight",cord))
			
			$$$THROWONERROR(tSC, ..PixelMap.%Push(point))
		}
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method GenerateFileName() As %Status [ Private ]
{
	Set tSC = $$$OK
	Try {
		If '##class(%File).DirectoryExists(..Directory) {
		    Set tSC = ##class(%File).CreateDirectoryChain(..Directory) 
		}   
		Set ..FileFullName = ..Directory_..Name_".jpg"
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method CreateImage() As %Status [ Private ]
{
	Set tSC = $$$OK
	Try {
		Set tBack = $ListFromString(..BackgroundColor,",")
		Set tImage = ##class(Ikon.Processor).New(..Size,..Size,$List(tBack,1),$List(tBack,2),$List(tBack,3))
		Do tImage.SetPen(..Color.%Get(0),..Color.%Get(1),..Color.%Get(2))
		Set iter = ..PixelMap.%GetIterator()
		While iter.%GetNext(.key,.value){
			Set posInicialX = value.topLeft.x
			Set posInicialY = value.topLeft.y
			Set posFinalX = value.bottomRight.x
			Set posFinalY = value.bottomRight.y
			For y=posInicialY:1:posFinalY{
				For x=posInicialX:1:posFinalX{
					Do tImage.Plot(x,y)
				}
			}
		}
		s a=..FileFullName
		o a:"WNS":10 e
		u a
		d tImage.WriteBitmap()
		c a
		d tImage.%Close()
	} Catch tException {
		Set:$$$ISOK(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method Generate(pName As %String = "Caché", pDirectory As %String = "", pSize = 250, Red As %Integer = 255, Green As %Integer = 255, Blue As %Integer = 255) As %Status
{
	Set tSC = $$$OK
	Try {
		Set:pName'="" ..Name = pName
		Set:pDirectory'="" ..Directory = pDirectory
		Set ..BackgroundColor = Red_","_Green_","_Blue
		Set ..Size = pSize
		$$$THROWONERROR(tSC, ..HashInput())
		$$$THROWONERROR(tSC, ..PickColor())
		$$$THROWONERROR(tSC, ..BuildGrid())
		$$$THROWONERROR(tSC, ..FilterOddSquares())
		$$$THROWONERROR(tSC, ..BuildPixelMap())
		$$$THROWONERROR(tSC, ..GenerateFileName())
		$$$THROWONERROR(tSC, ..CreateImage())
		Write !,"File '"_..Directory_..Name_"' successfully generated!",!
	} Catch tException {
		Set:$$$ISERR(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

Method %OnNew(pName As %String = "", pDirectory As %String = "", pSize = 250, Red As %Integer = 255, Green As %Integer = 255, Blue As %Integer = 255) As %Status [ Private, ServerOnly = 1 ]
{
	Set tSC = $$$OK
	Try {
		Set:pName'="" ..Name = pName
		Set:pDirectory'="" ..Directory = pDirectory
		Set ..BackgroundColor = Red_","_Green_","_Blue
		Set ..Size = pSize
		If pName'=""{
			$$$THROWONERROR(tSC, ..HashInput())
			$$$THROWONERROR(tSC, ..PickColor())
			$$$THROWONERROR(tSC, ..BuildGrid())
			$$$THROWONERROR(tSC, ..FilterOddSquares())
			$$$THROWONERROR(tSC, ..BuildPixelMap())
			$$$THROWONERROR(tSC, ..GenerateFileName())
			$$$THROWONERROR(tSC, ..CreateImage())
			Write !,"File '"_..Directory_..Name_"' successfully generated!",!
		}
	} Catch tException {
		Set:$$$ISERR(tSC) tSC = tException.AsStatus()
	}
	Quit tSC
}

}

