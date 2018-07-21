/* dbManager - wrapper over node-mongodb driver */

'use strict';

const dbManager = (logger) => {
  const log = logger;

  // Connection
  const pe = process.env;
  // use a cloud-hosted mongo db, such as mlab.com
  const url = `mongodb://${pe.user}:${pe.password}@${pe.db_host}:${pe.db_port}/${pe.db_name}`;

  let db = null;
  let collection = null;
  const adminDb = null;

  // connect to db
  const connect = () =>
    require('mongodb').MongoClient.connect(url, {
      poolSize: 20,
    }) // default poolsize = 5
      .then((dbInst) => {
        log.info(`Connected to mongodb at ${url}`);
        // get db, collection
        db = dbInst;
        // get existing collection, or create if doesn't exist
        // NOTE: Collections are not created until the first document is inserted
        collection = db.collection('khan-info');
      }).catch(err => log.error(err));

  // Mongo's UPSERT operation
  const upsert = doc =>
    // Update the document using an UPSERT operation, ensuring creation if it does not exist
    // does not change "_id" value
    collection.updateOne(
      { // criteria
      },
      doc, // use {$set: ...} to set just one field
      {
        upsert: true,
      },
    )
      .then(res => log.debug(`Inserted ${doc.title}`, res));

  // always close before exiting
  // https://docs.mongodb.com/manual/reference/method/db.collection.stats/#accuracy-after-unexpected-shutdown
  // can run validate() to verify correct stats
  const close = () => db.close()
    .then(() => log.info('DB closed successfully.'));

  return {
    close,
    connect,
    upsert,
  };
};

module.exports = dbManager;
