/*
type Token {
  	id:             	String!
	blockchain:      	String!
	fungible:        	Boolean!
	contractType:    	String!
	contractAddress:	String!

  	edition:         	Int64!
	editionName:     	String!
	mintAt:          	Time
	balance:         	Int64!
	owner:           	String!

	indexID:         	String!
	source:          	String!
	swapped:         	Boolean!
	burned:          	Boolean!
	provenance:			[Provenance!]!
	attributes: 		AssetAttributes
	lastActivityTime:  	Time
	lastRefreshedTime: 	Time
  	asset:           	Asset!
}

type Provenance {
	type:        String!
	owner:       String!
	blockchain:  String!
	blockNumber: Int64
	timestamp:   Time
	txID:        String!
	txURL:       String!
}

type AssetAttributes {
	scrollable:	Boolean!
}

type Asset {
	indexID:       		String!
	thumbnailID:   		String!
	lastRefreshedTime:	Time
	metadata:      		AssetMetadata!
}

type AssetMetadata {
  	project:  VersionedProjectMetadata!
}

type VersionedProjectMetadata {
  	origin:   ProjectMetadata!
  	latest:  ProjectMetadata!
}

type ProjectMetadata {
	artistID:            String!
	artistName:          String!
	artistURL:           String!
	assetID:             String!
	title:               String!
	description:         String!
	mimeType:            String!
	medium:              String!
	maxEdition:          Int64!
	baseCurrency:        String!
	basePrice:           Int64!
	source:              String!
	sourceURL:           String!
	previewURL:          String!
	thumbnailURL:        String!
	galleryThumbnailURL: String!
	assetData:           String!
	assetURL:            String!
}

type Identity {
	accountNumber:  String!
	blockchain:      String!
	name:            String!
}

type Query {
  tokens(owners: [String!]! = [], ids: [String!]! = [], lastUpdatedAt: Time, offset: Int64! = 0, size: Int64! = 50): [Token!]!
  identity(account: String!): Identity
}
 */

const String getTokens = r'''
  query getTokens($owners: [String!]! = [],$ids: [String!]! = [], $size: Int64! = 50, $lastUpdatedAt: Time, $offset: Int64! = 0) {
  tokens(owners: $owners,ids: $ids, size: $size, lastUpdatedAt: $lastUpdatedAt, offset: $offset) {
    id
    blockchain
    fungible
    contractType
    contractAddress
    edition
    editionName
    mintAt
    balance
    owner
    indexID
    source
    swapped
    burned
    lastActivityTime
    lastRefreshedTime
    attributes {
      scrollable
    }
    asset{
      indexID
      thumbnailID
      lastRefreshedTime
      metadata{
        project{
          origin{
            artistID
            artistName
            artistURL
            assetID
            title
            description
            mimeType
            medium
            maxEdition
            baseCurrency
            basePrice
            source
            sourceURL
            previewURL
            thumbnailURL
            galleryThumbnailURL
            assetData
            assetURL
            artworkMetadata
          }
          latest{
            artistID
            artistName
            artistURL
            assetID
            title
            description
            mimeType
            medium
            maxEdition
            baseCurrency
            basePrice
            source
            sourceURL
            previewURL
            thumbnailURL
            galleryThumbnailURL
            assetData
            assetURL
            artworkMetadata
          }
        }
      }
    }
  
  }
}
''';

// query documents to query tokens by owners
