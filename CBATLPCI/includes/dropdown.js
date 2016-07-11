//
// © 2002-2007, Microsoft Corporation. All rights reserved.
// Developed By Shavlik Technologies, LLC
//
var comboBoxArray = new Array();
var IPcomboBoxArray = new Array();
var SUScomboBoxArray = new Array();
var Edit = false;

document.onkeydown = keyHit;
function keyHit(evt) 
{
   if(!Edit)
     return top.keyHit(event);
   else
   {
     Edit = false;
     return true;
   }
}

function CreateComboBoxObject(strDropDownListID, strComboBoxName)
{
	this.Mycmb = document.all[strDropDownListID];
	this.SetDefaultText				= SetDefaultText;
	this.Mycmb.selectedIndex		= -1;
	this.UseStateFunctions			= false;
	this.Clear						= Clear;
	this.GetSelectedText			= GetSelectedText;
	this.AlignTextBoxOverDropDown	= AlignTextBoxOverDropDown;
	this.cbo_OnChange				= cbo_OnChange;
	this.txt_OnBlur					= txt_OnBlur; 
	this.txt_OnChange					= txt_OnChange; 
	this.setDefaultIndex			= setDefaultIndex;
	this.txt_OnKeyUp				= txt_OnKeyUp;
	this.txt_OnKeyDown				= txt_OnKeyDown;
	this.focus						= focus;
	//do lookup or not
	this.LookupValues				= true;
	this.SetAccessKey				= SetAccessKey;
	//case sensitivity
	this.LookupCaseInSensitive	= true;
	//store the previous text for the lookup
	this.MytxtPreviousValue			= "";
	//generate the text box on the fly
	
	var strMytxtID = "txtMytxt" + strDropDownListID;

	var strDummytxt = '<input type="text" ID="Text1" NAME="Text1" style="visibility: hidden; width:1"></input>';
	var strMytxt = strDummytxt + "<INPUT type='text' id=" + strMytxtID + " name=" + strMytxtID + " onblur='" + strComboBoxName + ".txt_OnBlur()' " + 
					   " onkeyup='" + strComboBoxName + ".txt_OnKeyUp()' " +
                                           " onkeydown='" + strComboBoxName + ".txt_OnKeyDown()' " +
					   " onchange='" + strComboBoxName + ".txt_OnChange()' " +
					   " style='display: none;' value='' >";

	this.Mycmb.insertAdjacentHTML("afterEnd", strMytxt);
	//assign obj to new textbox
	this.Mytxt = document.all[strMytxtID];

	var strMyHiddentxtID = strDropDownListID + "_value";
	
	var strMyHiddentxt = "<INPUT type='hidden' " + " id=" + strMyHiddentxtID + " name=" + strMyHiddentxtID + " >";

	this.Mycmb.insertAdjacentHTML("afterEnd", strMyHiddentxt);
	this.MyHiddentxt = document.all[strMyHiddentxtID];

	this.AdjustingSize = false;
	this.AlignTextBoxOverDropDown();

	comboBoxArray[comboBoxArray.length] = this;
}

function SetAccessKey(Key)
{
	this.Mytxt.accessKey = Key;
}

function CreateIPComboBoxObject(strDropDownListID, strComboBoxName)
{
	this.MyIPcmb = document.all[strDropDownListID];
	this.MyIPcmb.selectedIndex		= -1;
	this.UseStateFunctions		= false;
	this.AlignIPCombo	= AlignIPCombo;
	this.cboIP_OnChange				= cboIP_OnChange;
	this.cboIPRange_OnChange				= cboIPRange_OnChange;
	this.UseStateFunctions = false;
	this.AdjustingSize = false;
	this.IPAddressArrowUp = IPAddressArrowUp;
	this.IPAddressArrowDown = IPAddressArrowDown;
	this.IPRangeAddressArrowUp = IPRangeAddressArrowUp;
	this.IPRangeAddressArrowDown = IPRangeAddressArrowDown;
	this.AlignIPCombo();

	IPcomboBoxArray[IPcomboBoxArray.length] = this;
}

function CreateSUSComboBoxObject(strDropDownListID, strComboBoxName)
{
	this.MySUScmb = document.all[strDropDownListID];
	this.MySUScmb.selectedIndex		= -1;
	this.AlignSUSTextBoxOverDropDown	= AlignSUSTextBoxOverDropDown;
	this.GetSUSSelectedText			= GetSUSSelectedText;
	this.cboSUS_OnChange				= cboSUS_OnChange;
	this.DisableSUS = DisableSUS;
	this.EnableSUS = EnableSUS;
	this.AdjustingSize = false;
	this.SetDefaultSUSText			= SetDefaultSUSText;
	var strMytxtID = "txtMytxt" + strDropDownListID;
	var strMytxt = "<INPUT type='text' id=" + strMytxtID + " name=" + strMytxtID + " style='display: none; position: absolute' value='' >";
	this.MySUScmb.insertAdjacentHTML("afterEnd", strMytxt);
	//assign obj to new textbox
	this.MySUStxt = document.all[strMytxtID];

	this.AlignSUSTextBoxOverDropDown();
	SUScomboBoxArray[SUScomboBoxArray.length] = this;
}

function SetDefaultSUSText(Text)
{
	this.MySUScmb.selectedIndex = -1;
	this.MySUStxt.value = Text;
}

function DisableSUS()
{
	this.MySUScmb.disabled = true;
	this.MySUStxt.disabled = true;
}

function EnableSUS()
{
	this.MySUScmb.disabled = false;
	this.MySUStxt.disabled = false;
}

function AlignIPCombos()
{
	var iIndex;
	for (iIndex=0; iIndex < comboBoxArray.length; iIndex++)
	{
		IPcomboBoxArray[iIndex].AlignIPCombo();
	}
}

function AlignIPCombo()
{	
	if (!this.AdjustingSize)
	{
		var lastIPLeft = 0;
		var lastIPWidth = 0;
		
		this.AdjustingSize = true;
		this.MyIPcmb.style.width 	= 0;			// let the combo not interfere on the window size
		this.MyIPcmb.style.position	="static";
		this.MyIPcmb.style.posLeft	= GetAbsoluteXPosition(document.getElementById("IP1"));
		this.MyIPcmb.style.posTop	= GetAbsoluteYPosition(document.getElementById("IP1"));

		this.MyIPcmb.style.position	="absolute";

		if(document.all["IP5"] != null && document.all["IP5"] != 'undefined')
		{//must be an IP Range
			lastIPLeft = GetAbsoluteXPosition(document.getElementById("IP8"));
			lastIPWidth = document.getElementById("IP8").clientWidth;
		}
		else
		{//single IP
			lastIPLeft = GetAbsoluteXPosition(document.getElementById("IP4"));
			lastIPWidth = document.getElementById("IP4").clientWidth;
		}

		this.MyIPcmb.style.width = (lastIPLeft + lastIPWidth) - this.MyIPcmb.style.posLeft + 20;

        /*ISSUE: In High contrast mode, dropdown arrow of the Combobox is overlapping with the Textbox.
        This is due to standard width of '18' was used irrespective of display settings. To sort out it,
        clientWidth property of Combobox is used to dynamically calculate the arrow width based on display settings.
        clientWidth property is applicable on IE 7.0 only. Hence on IE 6.0 and below default width '18' will be used.
        */
        var clipRectWidth =0;
        var version=0;
        //Extract IE version from the string  "4.0 (compatible; MSIE 7.0; Windows NT 5.1; InfoPath.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)"
        if(navigator.appVersion.indexOf("MSIE") != -1)
        {
            var temp=navigator.appVersion.split("MSIE");
            version=parseFloat(temp[1]);
        }
        if(version >= 7.0) 
        {
            // 4 is assumed to be the gap between hidden text box and dropdown arrow of combobox
            clipRectWidth = this.MyIPcmb.offsetWidth - (this.MyIPcmb.offsetWidth - this.MyIPcmb.clientWidth)+4;
        }
        else
        {
            clipRectWidth = this.MyIPcmb.offsetWidth - 18;
        }

		var strClipRectangle = "rect(0 " + 
						(this.MyIPcmb.offsetWidth) + " " +
						this.MyIPcmb.offsetHeight + " " +
                        (clipRectWidth) + ")";

		this.MyIPcmb.style.clip = strClipRectangle;
		this.AdjustingSize = false;
	}
}

function AlignTextBoxesOverDropDowns()
{
	var iIndex;
	for (iIndex=0; iIndex < comboBoxArray.length; iIndex++)
	{
		comboBoxArray[iIndex].AlignTextBoxOverDropDown();
	}
}

//sets the default option
function SetDefaultText(Text)
{

	this.Mycmb.selectedIndex = -1;
	this.Mytxt.value = Text;
}


//Move the textbox over the Combo
function AlignTextBoxOverDropDown()
{	
	if (!this.AdjustingSize)
	{
		this.AdjustingSize = true;
		this.Mytxt.style.display="none";
		this.Mycmb.style.position="static";

		this.Mytxt.style.posLeft	= GetAbsoluteXPosition(this.Mycmb);
		this.Mytxt.style.posTop		= GetAbsoluteYPosition(this.Mycmb);

        //Please refer to above described comments in AlignIPCombo function.
        var version=0;
        if(navigator.appVersion.indexOf("MSIE") != -1)
        {
            var temp=navigator.appVersion.split("MSIE");
            version=parseFloat(temp[1]);
        }
        if(version >= 7.0)
        {
            // 4 is assumed to be the gap between hidden text box and dropdown arrow of combobox
            this.Mytxt.style.posWidth = this.Mycmb.offsetWidth - (this.Mycmb.offsetWidth - this.Mycmb.clientWidth) + 4;
        }
        else
        {
            this.Mytxt.style.posWidth = this.Mycmb.offsetWidth - 18;
        }

		this.Mytxt.style.posHeight	= this.Mycmb.offsetHeight;

		this.Mycmb.style.position	="absolute";
		this.Mycmb.style.posLeft	= this.Mytxt.style.posLeft;
		this.Mycmb.style.posTop	= this.Mytxt.style.posTop;
		
		this.ComboWidth = this.Mycmb.offsetWidth;
		var strClipRectangle = "rect(0 " + 
							(this.Mycmb.offsetWidth) + " " +
							this.Mycmb.offsetHeight + " " +
                            (this.Mytxt.style.posWidth) + ")";

		this.Mycmb.style.clip = strClipRectangle;
		this.Mytxt.style.display="";
		this.AdjustingSize = false;
	}

}

function AlignSUSCombos()
{
	var iIndex;
	for (iIndex=0; iIndex < SUScomboBoxArray.length; iIndex++)
	{
		SUScomboBoxArray[iIndex].AlignSUSTextBoxOverDropDown();
	}
}

function AlignSUSTextBoxOverDropDown()
{	
	if (!this.AdjustingSize)
	{
		this.AdjustingSize = true;
		this.MySUStxt.style.display="none";
		this.MySUScmb.style.position="absolute";

		this.MySUStxt.style.posLeft	= GetAbsoluteXPosition(document.getElementById("susMRUListContainer"));
		this.MySUStxt.style.posTop		= GetAbsoluteYPosition(document.getElementById("susMRUListContainer")) + 3;
		this.MySUStxt.style.posWidth	= this.MySUScmb.offsetWidth - 16;  // 16 THIS IS THE WIDTH OF THE DROP DOWN ARROW
		this.MySUStxt.style.posHeight	= this.MySUScmb.offsetHeight;

		this.MySUScmb.style.position	="absolute";
		this.MySUScmb.style.posLeft	= this.MySUStxt.style.posLeft;
		this.MySUScmb.style.posTop	= this.MySUStxt.style.posTop;
		
		this.ComboWidth = this.MySUScmb.offsetWidth;
		var strClipRectangle = "rect(0 " + 
							(this.MySUScmb.offsetWidth) + " " +
							this.MySUScmb.offsetHeight + " " +
							(this.MySUStxt.style.posWidth - 2 ) + ")";

		this.MySUScmb.style.clip = strClipRectangle;
		this.MySUStxt.style.display="";
		this.AdjustingSize = false;
	}

}
function Clear()
{
	this.Mytxt.value = "";
	this.Mycmb.selectedIndex = -1;
}

function GetAbsoluteXPosition(element)
{
	var pos = 0;
	while (element != null)
	{
		pos += element.offsetLeft;
		element = element.offsetParent;
	}

	return pos;
}

function GetAbsoluteYPosition(element)
{
	var pos = 0;
	while (element != null )
	{
		pos += element.offsetTop;
		element = element.offsetParent;
	}

	return pos;
}
function GetSUSSelectedText()
{
	return this.MySUStxt.value;
}

function GetSelectedText()
{
	return this.Mytxt.value;
}

function cboIP_OnChange()
{
	var tmpIndex = this.MyIPcmb.selectedIndex;
	var tempOption = this.MyIPcmb.options[tmpIndex];
	
	var IPArr = tempOption.text.split(".")
	if( IPArr.length == 4 )
	{
		document.all["IP1"].value = IPArr["0"];
		document.all["IP2"].value = IPArr["1"];
		document.all["IP3"].value = IPArr["2"];
		document.all["IP4"].value = IPArr["3"];
	}
	else
	{
		document.all["IP1"].value = "";
		document.all["IP2"].value = "";
		document.all["IP3"].value = "";
		document.all["IP4"].value = "";
	}

	this.MyIPcmb.selectedIndex=-1;
	if(this.UseStateFunctions) 
	{
		SetState("IP");
	}
}

function cboIPRange_OnChange()
{
	var tmpIndex = this.MyIPcmb.selectedIndex;
	var tempOption = this.MyIPcmb.options[tmpIndex];

	var IPRange = tempOption.text; 
	var IPArr = IPRange.split(/*locstart pickcomputers.to1/this is the word to that appears between the two IP addresses*/"to"/*locend*/)
	var IP1 = IPArr["0"].split(".");
	var IP2 = IPArr["1"].split(".");
	
	if( IP1.length == 4 && IP2.length == 4 )
	{
		document.all["IP1"].value = IP1["0"];
		document.all["IP2"].value = IP1["1"];
		document.all["IP3"].value = IP1["2"];
		document.all["IP4"].value = IP1["3"].substring(0,IP1["3"].length-1);
		document.all["IP5"].value = IP2["0"].substring(1,IP2["0"].length);
		document.all["IP6"].value = IP2["1"];
		document.all["IP7"].value = IP2["2"];
		document.all["IP8"].value = IP2["3"];
	}
	else
	{
		document.all["IP1"].value = "";
		document.all["IP2"].value = "";
		document.all["IP3"].value = "";
		document.all["IP4"].value = "";
		document.all["IP5"].value = "";
		document.all["IP6"].value = "";
		document.all["IP7"].value = "";
		document.all["IP8"].value = "";
	}
	
	if(this.UseStateFunctions) 
	{
		SetState("IP");
	}
	this.MyIPcmb.selectedIndex=-1;
}

function cbo_OnChange()
{
	var tmpIndex = this.Mycmb.selectedIndex;
	var tempOption = this.Mycmb.options[tmpIndex];
	this.Mytxt.value  = tempOption.text;
	
	this.Mytxt.focus();
	this.Mytxt.select();
	
	if(this.UseStateFunctions) 
	{
		SetState("CPU");
	}
	this.Mycmb.selectedIndex=-1;
	test_ThisComputer(this.Mytxt);
}

function cboSUS_OnChange()
{
	
	var tmpIndex = this.MySUScmb.selectedIndex;
	var tempOption = this.MySUScmb.options[tmpIndex];
	
	this.MySUStxt.value  = tempOption.text;
	
	this.MySUStxt.focus();
	this.MySUStxt.select();
	
	this.MySUScmb.selectedIndex=-1;
}

// This method trims white space off both ends of this string and returns the result.
function Trim(str)
{
	return(str.replace(/^\s*/,'').replace(/\s*$/,''));
}

function test_ThisComputer(control)
{
	if( ! document.all["thisComputerLabel"] )
		return;

	// assemble the domain\computername for this station
	thisComputerID = parent.Scanner.LocalDomain + "\\" + parent.Scanner.LocalMachine;
	isThisComputer = ( Trim(control.value.toUpperCase()) == Trim(thisComputerID.toUpperCase()) );

	if( isThisComputer )
	{
		document.all["thisComputerLabel"].value = Trim(parent.Scanner.ThisComputer);
	}
	else
	{
		document.all["thisComputerLabel"].value = "";
	}
}

function txt_OnKeyDown()
{
 if (this.LookupValues)
 {
     if (event.keyCode == 8)  
     {
        Edit = true;
     }
  }
}

function txt_OnKeyUp()
{		
	test_ThisComputer(this.Mytxt);
	if (this.LookupValues)
	{
		if (event.keyCode < 32)  
		{
			return;
		}
		else if (event.keyCode == 46)  
		{
			return;
		}
		else if (event.keyCode == 38)//up arrow  
		{
			var len = this.Mycmb.options.length;
			if(len > 0)
			{
				var tempString;
				var curText		= this.Mytxt.value;
				var FoundIndex = -1;
				for (var iIndex=0; iIndex<len; iIndex++)
				{
					tempString = this.Mycmb.options(iIndex).text;
					
					tempString = tempString.toUpperCase();
					curText = curText.toUpperCase();
					if (tempString == curText)
					{
						FoundIndex = iIndex;
					}
				}
				if(FoundIndex == -1)
				{
					//do nothing
				}
				else
				{
					if(FoundIndex > 0)
					{
						this.Mytxt.value = this.Mycmb.options(FoundIndex -1).text;
						var tmpRange = this.Mytxt.createTextRange();
						tmpRange.moveStart("character", this.Mytxt.length);
						tmpRange.select();
						SetState("CPU");
					}
				}
			}			
			test_ThisComputer(this.Mytxt);
			return;
		}
		else if (event.keyCode == 40)//Down arrow  
		{
			var len = this.Mycmb.options.length;
			if(len > 0)
			{
				var tempString;
				var curText		= this.Mytxt.value;
				var FoundIndex = -1;
			
				for (var iIndex=0; iIndex<len; iIndex++)
				{
					
					tempString = this.Mycmb.options(iIndex).text;	
					tempString = tempString.toUpperCase();
					curText = curText.toUpperCase();
					if (tempString == curText)
					{
						FoundIndex = iIndex;
					}
				}
				if(FoundIndex == -1)
				{
					this.Mytxt.value = this.Mycmb.options(0).text;
					var tmpRange = this.Mytxt.createTextRange();
					tmpRange.moveStart("character", this.Mytxt.length);
					tmpRange.select();
					SetState("CPU");
				}
				else
				{	
					if(FoundIndex < this.Mycmb.options.length - 1)
					{
						this.Mytxt.value = this.Mycmb.options(FoundIndex + 1).text;
						var tmpRange = this.Mytxt.createTextRange();
						tmpRange.moveStart("character", this.Mytxt.length);
						tmpRange.select();
						SetState("CPU");
					}
				}
			}
			test_ThisComputer(this.Mytxt);
			return;
		}
		if(this.UseStateFunctions) 
		{
			SetState("CPU");
		}
		var curText		= this.Mytxt.value;
		var prevText	= this.MytxtPreviousValue;
		var iIndex;

		if ((curText == "")	|| (curText == prevText))
		{
			this.MytxtPreviousValue = curText;
			return;
		}

		var len = this.Mycmb.options.length;
		var tempString;
		
		for (iIndex=0; iIndex<len; iIndex++)
		{
			tempString = this.Mycmb.options(iIndex).text;

			if (this.LookupCaseInSensitive)
			{
				tempString = tempString.toUpperCase();
				curText = curText.toUpperCase();
			}

			if (tempString.indexOf(curText) == 0)
			{
				var helperString = this.Mycmb.options(iIndex).text;

				this.Mytxt.value = this.Mytxt.value + helperString.substr(curText.length);
				this.Mycmb.selectedIndex = iIndex;
				this.MytxtPreviousValue = this.Mytxt.value;

				var tmpRange = this.Mytxt.createTextRange();
				tmpRange.moveStart("character", curText.length);
				tmpRange.select();
				test_ThisComputer(this.Mytxt);
				return;
			}
		}
	}
}

function txt_OnBlur()
{
	var myDropDownList	= this.Mycmb;
	var myEditCell		= this.Mytxt;
	var myHiddenCell	= this.MyHiddentxt;
	var iIndex;

        Edit = false;
	test_ThisComputer(this.Mytxt);

	myHiddenCell.value = myEditCell.value;
	myDropDownList.selectedIndex = -1;

	if (myEditCell.value == "")
	{
		return;
	}

	var len = myDropDownList.options.length;
	for (iIndex=0; iIndex<len; iIndex++)
	{
		var str1 = myDropDownList.options(iIndex).text;
		var str2 = myEditCell.value;

		if (this.LookupCaseInSensitive)
		{
			str1 = str1.toUpperCase();
			str2 = str2.toUpperCase();
		}
		
		if (str1 == str2)
		{
			myDropDownList.selectedIndex = iIndex;
			myHiddenCell.value = myDropDownList.options(iIndex).value;
			return;
		}
	}

	if (this._bOnlyAllowedEntries)
	{
		myDropDownList.focus();	

		alert(/* locstart js.notallow */"'"/* argstart value */ + myEditCell.value + /* argend */"' is not allowed"/* locend */);
		this.Mycmb.selectedIndex = -1;
		this.Mytxt.select();
		
		return;
	}
}

function txt_OnChange()
{
	test_ThisComputer(this.Mytxt);
	if(this.UseStateFunctions) 
	{
		SetState("CPU");
	}
}

function focus()
{
	this.Mycmb.focus();
}

function setDefaultIndex(iIndex)
{
	var len = this.Mycmb.options.length;
	if ((iIndex >=0) && (iIndex < len))
	{
		this.Mycmb.selectedIndex = iIndex;
		this.Mytxt.value = this.Mycmb.options(iIndex).text;
		this.MyHiddentxt.value = this.Mycmb.options(iIndex).value;
		return;
	}

	this.Mytxt.value = "";
}

function IPAddressArrowUp(curText)
{
	var len = this.MyIPcmb.options.length;
	if(len > 0)
	{
		var tempString;
		var FoundIndex = -1;
		var NewValue = "";
		for (var iIndex=0; iIndex<len; iIndex++)
		{
			tempString = this.MyIPcmb.options(iIndex).text;
			if (tempString.toString() == curText.toString())
			{
				FoundIndex = iIndex;
			}
		}
		if(FoundIndex == -1)
		{
			//do nothing
			NewValue = curText;
		}
		else
		{
			if(FoundIndex > 0)
			{
				NewValue = this.MyIPcmb.options(FoundIndex -1).text;
			}
		}
		return NewValue;
	}
	else
		return "";
}
function IPAddressArrowDown(curText)
{
	var len = this.MyIPcmb.options.length;
	if(len > 0)
	{
		var tempString;
		var NewValue = "";
		var FoundIndex = -1;
		for (var iIndex=0; iIndex<len; iIndex++)
		{
			tempString = this.MyIPcmb.options(iIndex).text;

			if (tempString.toString() == curText.toString())
			{
				FoundIndex = iIndex;
			}
		}
		if(FoundIndex == -1)
		{
			NewValue = this.MyIPcmb.options(0).text;
		}
		else
		{
			if(FoundIndex < this.MyIPcmb.options.length - 1)
			{
				NewValue = this.MyIPcmb.options(FoundIndex + 1).text;
			}
		}

		return NewValue;
	}
	else
		return "";
}

function IPRangeAddressArrowUp(curText)
{
	var len = this.MyIPcmb.options.length;
	
	if(len > 0)
	{
		var curIPArr = curText.split(/*locstart pickcomputers.to1/this is the word to that appears between the two IP addresses*/"to"/*locend*/);
		var curIP1 = curIPArr["0"].substring(0,curIPArr["0"].length -1);
		var curIP2 = curIPArr["1"].substring(1,curIPArr["1"].length -1);
	
		var tempString;
		var FoundIndex = -1;
		var NewValue = "";
		for (var iIndex=0; iIndex<len; iIndex++)
		{
			tempString = this.MyIPcmb.options(iIndex).text;
			
			var IPArr = tempString.split(/*locstart pickcomputers.to1/this is the word to that appears between the two IP addresses*/"to"/*locend*/);
			var IP1 = IPArr["0"].substring(0,IPArr["0"].length -1);
			var IP2 = IPArr["1"].substring(1,IPArr["1"].length -1);
			if (curIP1.toString() == IP1.toString() && curIP2.toString() == IP2.toString())
			{
				FoundIndex = iIndex;
			}
		}
		if(FoundIndex == -1)
		{
			//do nothing
			NewValue = curText;
		}
		else
		{
			if(FoundIndex > 0)
			{
				NewValue = this.MyIPcmb.options(FoundIndex -1).text;
			}
		}
		return NewValue;
	}
	else
		return "";
}

function IPRangeAddressArrowDown(curText)
{
	var len = this.MyIPcmb.options.length;
	
	if(len > 0)
	{
		var curIPArr = curText.split(/*locstart pickcomputers.to1/this is the word to that appears between the two IP addresses*/"to"/*locend*/);
		var curIP1 = curIPArr["0"].substring(0,curIPArr["0"].length -1);
		var curIP2 = curIPArr["1"].substring(1,curIPArr["1"].length -1);
	
		var tempString;
		var FoundIndex = -1;
		var NewValue = "";
		for (var iIndex=0; iIndex<len; iIndex++)
		{
			tempString = this.MyIPcmb.options(iIndex).text;
			
			var IPArr = tempString.split(/*locstart pickcomputers.to1/this is the word to that appears between the two IP addresses*/"to"/*locend*/);
			var IP1 = IPArr["0"].substring(0,IPArr["0"].length -1);
			var IP2 = IPArr["1"].substring(1,IPArr["1"].length -1);
			if (curIP1.toString() == IP1.toString() && curIP2.toString() == IP2.toString())
			{
				FoundIndex = iIndex;
			}
		}
		if(FoundIndex == -1)
		{
			//do nothing
			NewValue = curText;
		}
		else
		{
			if(FoundIndex < this.MyIPcmb.options.length - 1)
			{
				NewValue = this.MyIPcmb.options(FoundIndex + 1).text;
			}
		}
		return NewValue;
	}
	else
		return "";
	
}

// SIG // Begin signature block
// SIG // MIIa3AYJKoZIhvcNAQcCoIIazTCCGskCAQExCzAJBgUr
// SIG // DgMCGgUAMGcGCisGAQQBgjcCAQSgWTBXMDIGCisGAQQB
// SIG // gjcCAR4wJAIBAQQQEODJBs441BGiowAQS9NQkAIBAAIB
// SIG // AAIBAAIBAAIBADAhMAkGBSsOAwIaBQAEFNhCwJYAQpF1
// SIG // hWu67+2wZcs4af5NoIIVejCCBLswggOjoAMCAQICEzMA
// SIG // AABdycr2aSM3aFAAAAAAAF0wDQYJKoZIhvcNAQEFBQAw
// SIG // dzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
// SIG // b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
// SIG // Y3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWlj
// SIG // cm9zb2Z0IFRpbWUtU3RhbXAgUENBMB4XDTE0MDUyMzE3
// SIG // MTMxN1oXDTE1MDgyMzE3MTMxN1owgasxCzAJBgNVBAYT
// SIG // AlVTMQswCQYDVQQIEwJXQTEQMA4GA1UEBxMHUmVkbW9u
// SIG // ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MQ0wCwYDVQQLEwRNT1BSMScwJQYDVQQLEx5uQ2lwaGVy
// SIG // IERTRSBFU046N0QyRS0zNzgyLUIwRjcxJTAjBgNVBAMT
// SIG // HE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggEi
// SIG // MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCrunov
// SIG // r1QfdPQNc7LgC4VY7Kurv0cA/o03MfIckz6mus4b5lFA
// SIG // aNSAGNdYY10DNzb7g1hw3sQzNrBfB399/fdYq1qXbkXO
// SIG // uPEbPVLPpT0FQ5ugsTRy0+/zMbwuaI4qNQsudLDv5CtV
// SIG // cmWVj2f0o8jvAxGn3As8oWwO/2GMQpLkVsORsY/2rtfB
// SIG // 4+ioGQGiF2C/Q5h6KlpqNMiSDT/gXB23f7BaHb3MbGoR
// SIG // Qx4CDVtC6W1LYws5+1Kj7Hom0qIwR2PS+OoV2Gkunibp
// SIG // Tk8cs9LiYCY/bl2SFJBeNG14BHxSUZsLAXbrQQBZU87b
// SIG // jdZJhWyCO37E6YdGsjk88V7Yb3L/AgMBAAGjggEJMIIB
// SIG // BTAdBgNVHQ4EFgQU11TmFdnTXcok1QEY8HhkmXtoTDMw
// SIG // HwYDVR0jBBgwFoAUIzT42VJGcArtQPt2+7MrsMM1sw8w
// SIG // VAYDVR0fBE0wSzBJoEegRYZDaHR0cDovL2NybC5taWNy
// SIG // b3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljcm9z
// SIG // b2Z0VGltZVN0YW1wUENBLmNybDBYBggrBgEFBQcBAQRM
// SIG // MEowSAYIKwYBBQUHMAKGPGh0dHA6Ly93d3cubWljcm9z
// SIG // b2Z0LmNvbS9wa2kvY2VydHMvTWljcm9zb2Z0VGltZVN0
// SIG // YW1wUENBLmNydDATBgNVHSUEDDAKBggrBgEFBQcDCDAN
// SIG // BgkqhkiG9w0BAQUFAAOCAQEAiTCsbSNTPP+cXp9XcAwc
// SIG // 3hfdN6TclbGmJMwH7qmF0RzV2ZtJNyGfMT5prr+1MBvn
// SIG // pCxQ68FQiEqqteyosglAsGrvc1RCrZ4phVRtsw/xmH7j
// SIG // +MAwG0zShinwouVemzeNZp3ovFtvupXG9tIuQTX5x74M
// SIG // iuYmRHZoHJykFu4iVaTWVyv4DYEgLKEPmo78x5XFXoeE
// SIG // QeLSb5zP0GUjFtvQfYTQBhYSpWcte4WJPkWT2M0mmfu2
// SIG // KuFSQpoQlx802pHBrIbzkkRtULuJspHsNahI9sHhxP7G
// SIG // ZX1B7+1typHk5rDZ5VhctLua6JpGHGbdHktEmMn0SlgR
// SIG // f5DLITeIQ8je9TCCBOwwggPUoAMCAQICEzMAAADKbNUy
// SIG // EjXE4VUAAQAAAMowDQYJKoZIhvcNAQEFBQAweTELMAkG
// SIG // A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
// SIG // BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
// SIG // dCBDb3Jwb3JhdGlvbjEjMCEGA1UEAxMaTWljcm9zb2Z0
// SIG // IENvZGUgU2lnbmluZyBQQ0EwHhcNMTQwNDIyMTczOTAw
// SIG // WhcNMTUwNzIyMTczOTAwWjCBgzELMAkGA1UEBhMCVVMx
// SIG // EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
// SIG // ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
// SIG // dGlvbjENMAsGA1UECxMETU9QUjEeMBwGA1UEAxMVTWlj
// SIG // cm9zb2Z0IENvcnBvcmF0aW9uMIIBIjANBgkqhkiG9w0B
// SIG // AQEFAAOCAQ8AMIIBCgKCAQEAlnFd7QZG+oTLnVu3Rsew
// SIG // 4bQROQOtsRVzYJzrp7ZuGjw//2XjNPGmpSFeVplsWOSS
// SIG // oQpcwtPcUi8MZZogYUBTMZxsjyF9uvn+E1BSYJU6W7lY
// SIG // pXRhQamU4K0mTkyhl3BJJ158Z8pPHnGERrwdS7biD8XG
// SIG // J8kH5noKpRcAGUxwRTgtgbRQqsVn0fp5vMXMoXKb9CU0
// SIG // mPhU3xI5OBIvpGulmn7HYtHcz+09NPi53zUwuux5Mqnh
// SIG // qaxVTUx/TFbDEwt28Qf5zEes+4jVUqUeKPo9Lc/PhJiG
// SIG // cWURz4XJCUSG4W/nsfysQESlqYsjP4JJndWWWVATWRhz
// SIG // /0MMrSvUfzBAZwIDAQABo4IBYDCCAVwwEwYDVR0lBAww
// SIG // CgYIKwYBBQUHAwMwHQYDVR0OBBYEFB9e4l1QjVaGvko8
// SIG // zwTop4e1y7+DMFEGA1UdEQRKMEikRjBEMQ0wCwYDVQQL
// SIG // EwRNT1BSMTMwMQYDVQQFEyozMTU5NStiNDIxOGYxMy02
// SIG // ZmNhLTQ5MGYtOWM0Ny0zZmM1NTdkZmM0NDAwHwYDVR0j
// SIG // BBgwFoAUyxHoytK0FlgByTcuMxYWuUyaCh8wVgYDVR0f
// SIG // BE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQu
// SIG // Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljQ29kU2lnUENB
// SIG // XzA4LTMxLTIwMTAuY3JsMFoGCCsGAQUFBwEBBE4wTDBK
// SIG // BggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQu
// SIG // Y29tL3BraS9jZXJ0cy9NaWNDb2RTaWdQQ0FfMDgtMzEt
// SIG // MjAxMC5jcnQwDQYJKoZIhvcNAQEFBQADggEBAHdc69eR
// SIG // Pc29e4PZhamwQ51zfBfJD+0228e1LBte+1QFOoNxQIEJ
// SIG // ordxJl7WfbZsO8mqX10DGCodJ34H6cVlH7XPDbdUxyg4
// SIG // Wojne8EZtlYyuuLMy5Pbr24PXUT11LDvG9VOwa8O7yCb
// SIG // 8uH+J13oxf9h9hnSKAoind/NcIKeGHLYI8x6LEPu/+rA
// SIG // 4OYdqp6XMwBSbwe404hs3qQGNafCU4ZlEXcJjzVZudiG
// SIG // qAD++DF9LPSMBZ3AwdV3cmzpTVkmg/HCsohXkzUAfFAr
// SIG // vFn8/hwpOILT3lKXRSkYTpZbnbpfG6PxJ1DqB5XobTQN
// SIG // OFfcNyg1lTo4nNTtaoVdDiIRXnswggW8MIIDpKADAgEC
// SIG // AgphMyYaAAAAAAAxMA0GCSqGSIb3DQEBBQUAMF8xEzAR
// SIG // BgoJkiaJk/IsZAEZFgNjb20xGTAXBgoJkiaJk/IsZAEZ
// SIG // FgltaWNyb3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBS
// SIG // b290IENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0xMDA4
// SIG // MzEyMjE5MzJaFw0yMDA4MzEyMjI5MzJaMHkxCzAJBgNV
// SIG // BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
// SIG // VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
// SIG // Q29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBD
// SIG // b2RlIFNpZ25pbmcgUENBMIIBIjANBgkqhkiG9w0BAQEF
// SIG // AAOCAQ8AMIIBCgKCAQEAsnJZXBkwZL8dmmAgIEKZdlNs
// SIG // PhvWb8zL8epr/pcWEODfOnSDGrcvoDLs/97CQk4j1XIA
// SIG // 2zVXConKriBJ9PBorE1LjaW9eUtxm0cH2v0l3511iM+q
// SIG // c0R/14Hb873yNqTJXEXcr6094CholxqnpXJzVvEXlOT9
// SIG // NZRyoNZ2Xx53RYOFOBbQc1sFumdSjaWyaS/aGQv+knQp
// SIG // 4nYvVN0UMFn40o1i/cvJX0YxULknE+RAMM9yKRAoIsc3
// SIG // Tj2gMj2QzaE4BoVcTlaCKCoFMrdL109j59ItYvFFPees
// SIG // CAD2RqGe0VuMJlPoeqpK8kbPNzw4nrR3XKUXno3LEY9W
// SIG // PMGsCV8D0wIDAQABo4IBXjCCAVowDwYDVR0TAQH/BAUw
// SIG // AwEB/zAdBgNVHQ4EFgQUyxHoytK0FlgByTcuMxYWuUya
// SIG // Ch8wCwYDVR0PBAQDAgGGMBIGCSsGAQQBgjcVAQQFAgMB
// SIG // AAEwIwYJKwYBBAGCNxUCBBYEFP3RMU7TJoqV4ZhgO6gx
// SIG // b6Y8vNgtMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBB
// SIG // MB8GA1UdIwQYMBaAFA6sgmBAVieX5SUT/CrhClOVWeSk
// SIG // MFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwubWlj
// SIG // cm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL21pY3Jv
// SIG // c29mdHJvb3RjZXJ0LmNybDBUBggrBgEFBQcBAQRIMEYw
// SIG // RAYIKwYBBQUHMAKGOGh0dHA6Ly93d3cubWljcm9zb2Z0
// SIG // LmNvbS9wa2kvY2VydHMvTWljcm9zb2Z0Um9vdENlcnQu
// SIG // Y3J0MA0GCSqGSIb3DQEBBQUAA4ICAQBZOT5/Jkav629A
// SIG // sTK1ausOL26oSffrX3XtTDst10OtC/7L6S0xoyPMfFCY
// SIG // gCFdrD0vTLqiqFac43C7uLT4ebVJcvc+6kF/yuEMF2nL
// SIG // pZwgLfoLUMRWzS3jStK8cOeoDaIDpVbguIpLV/KVQpzx
// SIG // 8+/u44YfNDy4VprwUyOFKqSCHJPilAcd8uJO+IyhyugT
// SIG // pZFOyBvSj3KVKnFtmxr4HPBT1mfMIv9cHc2ijL0nsnlj
// SIG // VkSiUc356aNYVt2bAkVEL1/02q7UgjJu/KSVE+Traeep
// SIG // oiy+yCsQDmWOmdv1ovoSJgllOJTxeh9Ku9HhVujQeJYY
// SIG // XMk1Fl/dkx1Jji2+rTREHO4QFRoAXd01WyHOmMcJ7oUO
// SIG // jE9tDhNOPXwpSJxy0fNsysHscKNXkld9lI2gG0gDWvfP
// SIG // o2cKdKU27S0vF8jmcjcS9G+xPGeC+VKyjTMWZR4Oit0Q
// SIG // 3mT0b85G1NMX6XnEBLTT+yzfH4qerAr7EydAreT54al/
// SIG // RrsHYEdlYEBOsELsTu2zdnnYCjQJbRyAMR/iDlTd5aH7
// SIG // 5UcQrWSY/1AWLny/BSF64pVBJ2nDk4+VyY3YmyGuDVyc
// SIG // 8KKuhmiDDGotu3ZrAB2WrfIWe/YWgyS5iM9qqEcxL5rc
// SIG // 43E91wB+YkfRzojJuBj6DnKNwaM9rwJAav9pm5biEKgQ
// SIG // tDdQCNbDPTCCBgcwggPvoAMCAQICCmEWaDQAAAAAABww
// SIG // DQYJKoZIhvcNAQEFBQAwXzETMBEGCgmSJomT8ixkARkW
// SIG // A2NvbTEZMBcGCgmSJomT8ixkARkWCW1pY3Jvc29mdDEt
// SIG // MCsGA1UEAxMkTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNh
// SIG // dGUgQXV0aG9yaXR5MB4XDTA3MDQwMzEyNTMwOVoXDTIx
// SIG // MDQwMzEzMDMwOVowdzELMAkGA1UEBhMCVVMxEzARBgNV
// SIG // BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
// SIG // HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEh
// SIG // MB8GA1UEAxMYTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
// SIG // MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
// SIG // n6Fssd/bSJIqfGsuGeG94uPFmVEjUK3O3RhOJA/u0afR
// SIG // TK10MCAR6wfVVJUVSZQbQpKumFwwJtoAa+h7veyJBw/3
// SIG // DgSY8InMH8szJIed8vRnHCz8e+eIHernTqOhwSNTyo36
// SIG // Rc8J0F6v0LBCBKL5pmyTZ9co3EZTsIbQ5ShGLieshk9V
// SIG // UgzkAyz7apCQMG6H81kwnfp+1pez6CGXfvjSE/MIt1Nt
// SIG // UrRFkJ9IAEpHZhEnKWaol+TTBoFKovmEpxFHFAmCn4Tt
// SIG // VXj+AZodUAiFABAwRu233iNGu8QtVJ+vHnhBMXfMm987
// SIG // g5OhYQK1HQ2x/PebsgHOIktU//kFw8IgCwIDAQABo4IB
// SIG // qzCCAacwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU
// SIG // IzT42VJGcArtQPt2+7MrsMM1sw8wCwYDVR0PBAQDAgGG
// SIG // MBAGCSsGAQQBgjcVAQQDAgEAMIGYBgNVHSMEgZAwgY2A
// SIG // FA6sgmBAVieX5SUT/CrhClOVWeSkoWOkYTBfMRMwEQYK
// SIG // CZImiZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJ
// SIG // bWljcm9zb2Z0MS0wKwYDVQQDEyRNaWNyb3NvZnQgUm9v
// SIG // dCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHmCEHmtFqFKoKWt
// SIG // THNY9AcTLmUwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDov
// SIG // L2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVj
// SIG // dHMvbWljcm9zb2Z0cm9vdGNlcnQuY3JsMFQGCCsGAQUF
// SIG // BwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3d3dy5t
// SIG // aWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNyb3NvZnRS
// SIG // b290Q2VydC5jcnQwEwYDVR0lBAwwCgYIKwYBBQUHAwgw
// SIG // DQYJKoZIhvcNAQEFBQADggIBABCXisNcA0Q23em0rXfb
// SIG // znlRTQGxLnRxW20ME6vOvnuPuC7UEqKMbWK4VwLLTiAT
// SIG // UJndekDiV7uvWJoc4R0Bhqy7ePKL0Ow7Ae7ivo8KBciN
// SIG // SOLwUxXdT6uS5OeNatWAweaU8gYvhQPpkSokInD79vzk
// SIG // eJkuDfcH4nC8GE6djmsKcpW4oTmcZy3FUQ7qYlw/FpiL
// SIG // ID/iBxoy+cwxSnYxPStyC8jqcD3/hQoT38IKYY7w17gX
// SIG // 606Lf8U1K16jv+u8fQtCe9RTciHuMMq7eGVcWwEXChQO
// SIG // 0toUmPU8uWZYsy0v5/mFhsxRVuidcJRsrDlM1PZ5v6oY
// SIG // emIp76KbKTQGdxpiyT0ebR+C8AvHLLvPQ7Pl+ex9teOk
// SIG // qHQ1uE7FcSMSJnYLPFKMcVpGQxS8s7OwTWfIn0L/gHkh
// SIG // gJ4VMGboQhJeGsieIiHQQ+kr6bv0SMws1NgygEwmKkgk
// SIG // X1rqVu+m3pmdyjpvvYEndAYR7nYhv5uCwSdUtrFqPYmh
// SIG // dmG0bqETpr+qR/ASb/2KMmyy/t9RyIwjyWa9nR2HEmQC
// SIG // PS2vWY+45CHltbDKY7R4VAXUQS5QrJSwpXirs6CWdRrZ
// SIG // kocTdSIvMqgIbqBbjCW/oO+EyiHW6x5PyZruSeD3AWVv
// SIG // iQt9yGnI5m7qp5fOMSn/DsVbXNhNG6HY+i+ePy5VFmvJ
// SIG // E6P9MYIEzjCCBMoCAQEwgZAweTELMAkGA1UEBhMCVVMx
// SIG // EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
// SIG // ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
// SIG // dGlvbjEjMCEGA1UEAxMaTWljcm9zb2Z0IENvZGUgU2ln
// SIG // bmluZyBQQ0ECEzMAAADKbNUyEjXE4VUAAQAAAMowCQYF
// SIG // Kw4DAhoFAKCB5zAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
// SIG // NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
// SIG // FTAjBgkqhkiG9w0BCQQxFgQUsbY6WZ9TAH45U5lbroqn
// SIG // SbCWm5AwgYYGCisGAQQBgjcCAQwxeDB2oFKAUABNAGkA
// SIG // YwByAG8AcwBvAGYAdAAgAEIAYQBzAGUAbABpAG4AZQAg
// SIG // AFMAZQBjAHUAcgBpAHQAeQAgAEEAbgBhAGwAeQB6AGUA
// SIG // cgAgADIALgAzoSCAHmh0dHA6Ly93d3cubWljcm9zb2Z0
// SIG // LmNvbS9tYnNhIDANBgkqhkiG9w0BAQEFAASCAQBQH1Yt
// SIG // Cb7E4Ov+0hTe/Quz78QxjC6yC2zo6MlSN7833TF6/UPt
// SIG // jEn6KQe8OdVCepC4b5HZ+kgl+WpKckfE+LFXCOxN3bdo
// SIG // XtvEEPv8+XWSCeqstjnV2B9c2LrO7mZGOrSmkbqgU2xk
// SIG // eKFHW8RUkll0G7u8cV0LKnOI8tE63VqX9Uj+be/HnHG3
// SIG // Qr5Lu2C05x9MHbzHVKLBqu+d7UxSCaj8B2xxmuLtAoSG
// SIG // ddCYuqCFbCCuLd6nBBdDN7YkIhJUjqo/W2w6KcYCKkGb
// SIG // Vqd0Bvrf+qw68p9J9RKGGy7XK2iNO0Y9wadfpdyacNls
// SIG // wJttf3t33FwnqKHliuRxAgboTbCCoYICKDCCAiQGCSqG
// SIG // SIb3DQEJBjGCAhUwggIRAgEBMIGOMHcxCzAJBgNVBAYT
// SIG // AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
// SIG // EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
// SIG // cG9yYXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBUaW1l
// SIG // LVN0YW1wIFBDQQITMwAAAF3JyvZpIzdoUAAAAAAAXTAJ
// SIG // BgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3
// SIG // DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUwMTA3MTcxNjMy
// SIG // WjAjBgkqhkiG9w0BCQQxFgQUG/w2Vj0iZNe8O64GeiIQ
// SIG // kJxITwYwDQYJKoZIhvcNAQEFBQAEggEADPQ1d9WdJi+f
// SIG // vmd/G0t8uZeuRBP1J9q54Yvc2Qnt4GACRhLCBVRdj1B5
// SIG // QH5IvYB5g75JLB3IuqDU96oM0cC+oMLn0Je7MYrndFQD
// SIG // sBlxGJiJ8T8v4gJnnxtqpIlL/SbxGcn0XXp88VnLfkRk
// SIG // 8Ou/hgUlTivpSfy2AMun9CFqFvKtXK8MeFMM0AaNX8e9
// SIG // N8a67oYlp0U+P7VINw+hW6eXPdv/ipJeHyGkN3d+W+8B
// SIG // kUd4HOe+49X7hdQBnvQb44tod71lJ9D1syM0kR1RpDYl
// SIG // GlZDW2qRbqrVjPBr5BjrwtTfp40yAO3OI+8SlEjfomFU
// SIG // z8uxAKe1Y1rU7yB2UQ9s9w==
// SIG // End signature block
