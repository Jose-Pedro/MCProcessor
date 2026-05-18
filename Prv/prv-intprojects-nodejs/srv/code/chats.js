const { UserCode } = require('./users')

class ChatsCode {

    onBeforeInsertChat = async oRequest => {
        await UserCode.currentUserDetails(oRequest)
        if (oRequest.agoraCurrentUserData.hasNoCountry) oRequest.error(401, 'notAuthorizedNoCountry')

        if ('data' in oRequest) {
            oRequest.data.userId = oRequest.user.id
            oRequest.data.date = oRequest.timestamp
        }
    }

}

module.exports = { 
    ChatsCode
}