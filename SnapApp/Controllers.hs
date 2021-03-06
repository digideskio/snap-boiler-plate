{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

module SnapApp.Controllers where

import           Control.Monad.Reader (ask)
import           Control.Monad.State  (get, put)
import           Data.ByteString (ByteString)  
import qualified Data.IxSet as IxSet
import           Data.String (fromString)


import           SnapApp.Models

import           Snap.Snaplet.AcidState (Update, Query, Acid,
                 HasAcid (getAcidStore), makeAcidic, update, query, acidInit)

------------------------------------------------------------------------------
-- Seperate our Controller Functions. This way it is explicit that our models
-- are not based on Acid State
------------------------------------------------------------------------------

-- | Change a User
changeUser :: OpenIdUser -> Update ApplicationState ()
changeUser uu = do
    a@ApplicationState{..} <- get
    put $ a { allUsers = IxSet.updateIx (openIdIdentifier uu) uu allUsers }

-- | Look up a user by name
lookupName :: ByteString -> Query ApplicationState (Maybe OpenIdUser)
lookupName ui = do
	ApplicationState {..} <- ask
	return $ IxSet.getOne $ allUsers IxSet.@= ui

-- | Look up a user by OpenID
lookupOpenIdUser :: ByteString -> Query ApplicationState (Maybe OpenIdUser)
lookupOpenIdUser ui = do
	ApplicationState {..} <- ask
	return $ IxSet.getOne $ allUsers IxSet.@= ui

-- | Insert a user (Note, this does not check for unique ID)
insertNewOpenIdUser :: ByteString -> ByteString -> ByteString -> ByteString -> Update ApplicationState OpenIdUser
insertNewOpenIdUser uuid openident nname passphrase = do
    a@ApplicationState{..} <- get
    let newUser = OpenIdUser { uniqueIdentifier = uuid
                             , openIdIdentifier = openident
    						 , name = nname
                             , uploadPassPhrase = passphrase
                             }
    put $ a { allUsers = IxSet.insert newUser allUsers }
    return newUser

makeAcidic ''ApplicationState ['lookupOpenIdUser, 'insertNewOpenIdUser, 'changeUser, 'lookupName]