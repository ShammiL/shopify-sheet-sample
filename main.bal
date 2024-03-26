import ballerina/http;
import ballerina/log;
import ballerinax/googleapis.sheets as sheets;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string spreadSheetId = ?;

type ShopifyOrder record {
    int order_number;
    string total_price;
};

sheets:ConnectionConfig spreadsheetConfig = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: refreshToken
    }
};

sheets:Client spreadsheetClient = check new (spreadsheetConfig);

service /orders on new http:Listener(9090) {
    resource function post update\-sheet(ShopifyOrder shopifyOrder) {
        log:printInfo("Received order with number: " + shopifyOrder.order_number.toString());
        sheets:ValueRange|error errResponse = spreadsheetClient->appendValue(spreadSheetId,
            [shopifyOrder.order_number, shopifyOrder.total_price], {sheetName: "OrderUpdates"});
        if errResponse is error {
            log:printError("Error updating the sheet");
            return;
        }
    }
}

public function addSpreadSheet() {
    sheets:Spreadsheet|error response = spreadsheetClient->createSpreadsheet("ShopifyUpdates");
    if (response is sheets:Spreadsheet) {
        log:printInfo(string `sheet URL: ${response.spreadsheetUrl}`);
        log:printInfo(string `sheet id: ${response.spreadsheetId}`);
    } else {
        log:printError("Error: " + response.toString());
    }
}

public function addWorkSheet(string spreadSheetId, string name) {
    sheets:Sheet|error sheet = spreadsheetClient->addSheet(spreadSheetId, name);
    if (sheet is sheets:Sheet) {
        log:printInfo("Sheet Details: " + sheet.toString());
    } else {
        log:printError("Error: " + sheet.toString());
    }
}