
function toggle_visibility(divDisplayName, divHideName) {
    var showContents = document.getElementById(divDisplayName);
    var hideContents = document.getElementById(divHideName);
    showContents.style.display = "block";
    hideContents.style.display = "none";
}

function toggleCertDetails(divID)
{
    var toggleContents = document.getElementByClassName("CertEffDetails");

    for (var i = 0; i < toggleContents.length; i++) {
        if(toggleContents[i].divID.toggle_visibility = true)
            for (var i = 0; i < toggleContents.length; i++) {
                if (toggleContents[i].divID.toggle_visibility = true)
                    toggleContents[i].divID.display = "block";
                else
                    toggleContents[i].divID.display = "none";
            }
    }
}

function isFloat(val) {
    var floatRegex = /^-?\d+(?:[.,]\d*?)?$/;
    if (!floatRegex.test(val))
        return false;

    val = parseFloat(val);
    if (isNaN(val))
        return false;
    return true;
}

function isInt(val) {
    var intRegex = /^-?\d+$/;
    if (!intRegex.test(val))
        return false;

    var intVal = parseInt(val, 10);
    return parseFloat(val) == intVal && !isNaN(intVal);
}

function validatedate(inputText)
{
    var dateformat = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/;
    // Match the date format through regular expression
    if(inputText.value.match(dateformat))
    {
        document.form1.text1.focus();
        //Test which seperator is used '/' or '-'
        var opera1 = inputText.value.split('/');
        var opera2 = inputText.value.split('-');
        lopera1 = opera1.length;
        lopera2 = opera2.length;
        // Extract the string into month, date and year
        if (lopera1>1)
        {
            var pdate = inputText.value.split('/');
        }
        else if (lopera2>1)
        {
            var pdate = inputText.value.split('-');
        }
        var dd = parseInt(pdate[0]);
        var mm  = parseInt(pdate[1]);
        var yy = parseInt(pdate[2]);
        // Create list of days of a month [assume there is no leap year by default]
        var ListofDays = [31,28,31,30,31,30,31,31,30,31,30,31];
        if (mm==1 || mm>2)
        {
            if (dd>ListofDays[mm-1])
            {
                alert('Invalid date format!');
                return false;
            }
        }
        if (mm==2)
        {
            var lyear = false;
            if ( (!(yy % 4) && yy % 100) || !(yy % 400)) 
            {
                lyear = true;
            }
            if ((lyear==false) && (dd>=29))
            {
                alert('Invalid date format!');
                return false;
            }
            if ((lyear==true) && (dd>29))
            {
                alert('Invalid date format!');
                return false;
            }
        }
    }
    else
    {
        alert("Invalid date format!");
        document.form1.text1.focus();
        return false;
    }
}

function researchdb_Currency(data)
{
    var formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 2,
    });

    var stringArray = formatter.format(data).split('$');

    if (stringArray.length == 2)
    { return stringArray[1]; }
    else {
        return 'Error';
    }
}

$(document).ready(
    function() { 
        //$('.datatables-Home').DataTable();
    }
);

