function onOpen() {
  var ui = SpreadsheetApp.getUi();
    ui.createAddonMenu()
        .addItem('Annotate selection', 'annotateSelection')
        .addToUi();

}

function showSidebar() {
  var html = (HtmlService.createTemplateFromFile('Sidebar').evaluate())
       .setSandboxMode(HtmlService.SandboxMode.IFRAME)
       .setTitle('Ontology Annotation')
  SpreadsheetApp.getUi() 
        .showSidebar(html);
}

function getSelectedCell() {
  // get selected cells
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getActiveSheet();
  // Returns the active range
  var range = sheet.getActiveRange();
  var val = range.getValue();
  
  Logger.log("selected cell: " + val);

  return val;
}

function annotateSelection() {
 
  // get selected cells
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getActiveSheet();
  // Returns the active range
  var range = sheet.getActiveRange();
  var numRows = range.getNumRows();
  var numCols = range.getNumColumns();
    
  Logger.log("range selected");
  for (var i = 1; i <= numRows; i++) {
    for (var j = 1; j <= numCols; j++) {
      var currentValue = range.getCell(i,j).getValue();
      if (currentValue) {
        Logger.log("selected %s", currentValue);
        
        var result = getZoomaResult(currentValue);
        var hasResult = false;
        
        if (result.length > 0) {
          hasResult = true;
          var conf = result[0].confidence;
          Logger.log("cond %s", conf);
          
          if (conf == "HIGH") {
            range.getCell(i,j).setBackgroundRGB(223,254,223);
          }
          else if (conf == "GOOD" || conf == "MEDIUM" || conf == "LOW") {
            range.getCell(i,j).setBackgroundRGB(255,252,199);
          }
        }
                
        
                                  

        if (!hasResult) {

          var result = getNcboResult(currentValue)

          if (result.collection.length > 0) {
            hasResult=true;
            range.getCell(i,j).setBackgroundRGB(255,252,199);
          }          
        }

        
        //if (!hasResult) {
         // range.getCell(i,j).setBackgroundRGB(245, 147, 147);
        //}        
      }
    }
  }
  
  showSidebar();

}

function getNcboResult (q) {
  var agroUrl = "http://data.agroportal.lirmm.fr/search?q=" + q + "&include=prefLabel,synonym"
  + "&require_exact_match=flase"
  + "&no_links=false"
  + "&no_context=true"
  + "&apikey=56895a33-7a5b-4540-8bc1-06d177dba33c"
  + "&pagesize=5";  
  Logger.log("searching %s", agroUrl);

  return getObjectFromUrl(agroUrl)  
  
  
}

function getZoomaResult (q) {
  var zoomaUrl = "http://www.ebi.ac.uk/spot/zooma/v2/api/services/annotate?propertyValue=" + q
  return getObjectFromUrl(zoomaUrl)          
}

/**
 *
 * Get json from a URL and return as a generic object

 * @param {string} uri The URI of the document server
 * @return {object} new object parsed from JSON
 */
function getObjectFromUrl(uri){
  try {
    var result = UrlFetchApp.fetch(uri).getContentText();
    if (result != null) {
      return JSON.parse(result);
    } else {
      throw new Error("No results from " + uri);
    }
  } catch (e) {
    throw new Error("Can't query " + uri);
  }
}