{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE TemplateHaskell            #-}

module SnapApp.Models where
    
import           Data.ByteString (ByteString)
import           Data.SafeCopy (base, deriveSafeCopy)
import           Data.Typeable (Typeable)
import qualified Data.IxSet as IxSet
import           Data.IxSet ( Indexable(..), IxSet(..), ixFun, ixSet )

------------------------------------------------------------------------------
-- Our Models. In this case built on IxSet. Seperating them from Acid State
-- code makes sure we know that we are using native Haskell DataTypes
------------------------------------------------------------------------------

data OpenIdUser = OpenIdUser
    { uniqueIdentifier  :: ByteString
    , openIdIdentifier  :: ByteString
    , name              :: ByteString
    , uploadPassPhrase  :: ByteString
    } deriving (Show, Eq, Ord, Typeable) 

deriveSafeCopy 0 'base ''OpenIdUser

instance Indexable OpenIdUser where
    empty = ixSet [ ixFun $ \u -> [openIdIdentifier u]
                  , ixFun $ \u -> [name u]
                  , ixFun $ \u -> [uniqueIdentifier u] ]

	
data ApplicationState = ApplicationState
    { allUsers           :: IxSet OpenIdUser
    } deriving (Show,Ord,Eq,Typeable)

initApplicationState = ApplicationState 
    { allUsers           = IxSet.empty }

deriveSafeCopy 0 'base ''ApplicationState