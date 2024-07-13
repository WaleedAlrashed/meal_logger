function doGet(e) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    const rows = sheet.getDataRange().getValues();
    const jsonData = [];
  
    for (let i = 1; i < rows.length; i++) {
      const row = rows[i];
      jsonData.push({
        mealName: row[1],
        date: row[2],
        time: row[3],
        location: row[4],
        notes: row[5],
      });
    }
  
    return ContentService.createTextOutput(JSON.stringify(jsonData)).setMimeType(ContentService.MimeType.JSON);
  }
  
  function doPost(e) {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    const data = JSON.parse(e.postData.contents);
  
    const newRow = [
      sheet.getLastRow() -1, // Number
      data.mealName,
      data.date,
      data.time,
      data.location,
      data.notes || "" // Notes
    ];
  
    sheet.appendRow(newRow);
  
    return ContentService.createTextOutput(JSON.stringify({result: "success"})).setMimeType(ContentService.MimeType.JSON);
  }
  