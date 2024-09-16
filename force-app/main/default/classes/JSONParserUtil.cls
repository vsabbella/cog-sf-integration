@isTest(seealldata=false)
public class JSONParserUtil {
    private static testmethod void parseJSONResponse() {        
        
       String JSONResponse = '[{"label":"Summer \'14","url":"/services/data/v31.0","version":"31.0"},{"label":"Winter \'15","url":"/services/data/v32.0","version":"32.0"},{"label":"Spring \'15","url":"/services/data/v33.0","version":"33.0"}]';
        /* The JSON response returned is the following:
            {"label":"Summer '14","url":"/services/data/v31.0","version":"31.0"},
            {"label":"Winter '15","url":"/services/data/v32.0","version":"32.0"},
            {"label":"Spring '15","url":"/services/data/v33.0","version":"33.0"},
        */
        // Parse JSON response to build a map from API version numbers to labels
        JSONParser parser = JSON.createParser(JSONResponse);
        Map<double, string> apiVersionToReleaseNameMap = new Map<double, string>();
        
        string label = null;
        double version = null;
        
        while (parser.nextToken() != null) {
            
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                System.debug(LoggingLevel.DEBUG,parser.getText());
                System.debug(LoggingLevel.DEBUG,JSONToken.FIELD_NAME);
                switch on parser.getText() {
                    when 'label' {
                    // Advance to the label value.
                    parser.nextToken();
                        label = parser.getText();
                    }
                    when 'version' {
                        // Advance to the version value.
                        parser.nextToken();
                        version = Double.valueOf(parser.getText());
                    }
                }
            }
            
            if(version != null && String.isNotEmpty(label)) {
                apiVersionToReleaseNameMap.put(version, label);
                version = null;
                label = null; 
            }
        }
        system.debug('Release with Rainbow logo = ' +
            apiVersionToReleaseNameMap.get(39.0D));
    }
}