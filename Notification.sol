pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

contract Notification {
    struct Notif {
        string title;
        string content;
        string senderName;
        uint256 publishTime;
    }

    Notif[] public notifications;
    address private _owner;

    constructor() public{
        _owner = msg.sender;
    }
    
    function postNotification(string memory title, string memory content, string memory senderName) public {
        require(msg.sender == _owner, "Only the contract owner may publish a notification.");
        if (keccak256(abi.encodePacked(senderName))== keccak256(abi.encodePacked(""))) {
            senderName = "engrave org";
        }
        notifications.length ++;
        notifications[notifications.length - 1] = Notif(title, content, senderName, now);
    }
    
    function getLatestNotification() public view returns (string memory title, string memory content, string memory senderName, uint256 publishTime) {
        if (notifications.length > 0) {
            return (
                notifications[notifications.length - 1].title,
                notifications[notifications.length - 1].content,
                notifications[notifications.length - 1].senderName,
                notifications[notifications.length - 1].publishTime
            );
        }
        return ('', '', '', 0);
    }

    function getNotificationCount() public view returns (uint256 cnt) {
        return notifications.length;
    }

    function getNotificationsBetween(uint256 startPos, uint256 endPos) 
        public view returns (
            string[] memory title,
            string[] memory content,
            string[] memory senderName,
            uint256[] memory publishTime) {
        require(startPos >= 0 && endPos >= startPos && endPos < notifications.length , "Invalid positions.");
        title = new string[](endPos - startPos + 1);
        content = new string[](endPos - startPos + 1);
        senderName = new string[](endPos - startPos + 1);
        publishTime = new uint256[](endPos - startPos + 1);
        for (uint256 i = startPos; i <= endPos; i ++) {
            title[i - startPos] = notifications[i].title;
            content[i - startPos] = notifications[i].content;
            senderName[i - startPos] = notifications[i].senderName;
            publishTime[i - startPos] = notifications[i].publishTime;
        }
    }
}