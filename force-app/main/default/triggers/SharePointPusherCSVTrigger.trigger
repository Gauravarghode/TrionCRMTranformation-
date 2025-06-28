trigger SharePointPusherCSVTrigger on SharePointPusherCSV__e (after insert) {
    List<SharePointPusherCSV__e> trionFilesList = new List<SharePointPusherCSV__e>();
    
    for (SharePointPusherCSV__e trionFile : Trigger.new) {
        // Process each platform event record
        System.debug('Received platform event: ' + trionFile);
                SharePointPusherHandlerCSV.subscribeEvents(trigger.new);

        // Add your processing logic here
    }
}