
function dateFromSortDate(number) {
  var y = Number(number.toString().slice(0,4));
  var m = Number(number.toString().slice(4,6));
  var d = Number(number.toString().slice(6,8));
  return new Date(y,m-1,d);
}

function gleanType(propName, propValue) {

  propValue = propValue.trim();
  numberValue = Number(propValue.replace(/[,$]/gm,''));
  if (!isNaN(numberValue)) { propValue = Number(numberValue); };
  if (propName == 'date')  { propValue = dateFromSortDate(propValue); };
  return propValue;
}

function getPrimaryData(row) {

  // hide details "expansion" link
  row.cells[0].children[0].hidden = true;
  var cellData = {};
  for (const cell of row.cells) {

    var propName = cell.headers;
    var propValue;

    if (cell.hasAttribute("sortvalue")) {
      propValue = gleanType(propName, cell.getAttribute("sortvalue"));
    } else {
      propValue = gleanType(propName, cell.innerText);
    }

    Object.defineProperty(cellData, propName, { 
      value: propValue,
      writable: false
    });
  }
  return cellData;
}


function getTableData() {
  
  var dataTable = document.querySelector("#sortable");
  var ret = [];

  var ti = -1;

  for (const ch of dataTable.children) {

    // INCREMENT ROW ITERATOR...
    ti++;

    // SKIP THEAD... ONLY PROCESS TBODY (GROUPINGS OF DATA)
    if (ch.tagName == "TBODY") {

      var rowCount= ch.rows.length;

      // FIRST ROW IS PRIMARY DATA
      var rowData = {};
      rowData = getPrimaryData(ch.rows[0]);
      rowData.index = ti;
      rowData.sources = {};

      // SKIP "sources" LABEL ROW... start on index 2. (zero-based)
      for (var i = 2; i < rowCount; i++ ) {

        const propNames = [];
        propNames[1] = 'preTax';
        propNames[3] = 'roth401k';
        propNames[6] = 'employerMatch';
        propNames[24] = 'profitShare';

        var propName;
        var code;
        var description;
        var amount;
        var currency;
        var shares;

        // SPLIT TRANSACTION CODE/DESCRIPTION
        [code, description] = ch.rows[i].cells[1].innerText.split(" - ");
        code = Number(code);

        if (propNames[code] != null) {
          
          propName = propNames[code];

          currency = "USD";

          // DETAIL USD AMOUNT AND SHARE VOLUME
          if (ch.rows[i].cells[2].hasAttribute("sortvalue")) {
            amount = gleanType(propName, ch.rows[i].cells[2].getAttribute("sortvalue"));
          } else {
            amount = gleanType(propName, ch.rows[i].cells[2].innerText);
          }

          shares = gleanType(propName, ch.rows[i].cells[3].innerText);

          Object.defineProperty( rowData.sources, propName, {
            value: {
              code: code,
              description: description,
              amount: amount,
              currency: currency,
              shares: shares
            },
            writable: false
          });

        } else {

          console.log("getTableData: Unknown source " + ch.rows[i].cells[1].innerText + " in group_details for index " + ti + ".");
        }
      }
      ret.push(rowData);
    }
  }
  return ret;
}


function getData() {

  // get data
  var data = getTableData();

  // HIDES DETAILS LINK
  // dataTable.rows[1].cells[0].children[0].hidden = true;
  return data;

}

function start() {
  url.location = 'https://retiretxn.fidelity.com/nbretail/savings2/navigation/dc/History'
}
