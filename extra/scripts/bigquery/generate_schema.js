const {BigQuery} = require('@google-cloud/bigquery');
const fs = require('fs')

/*
    Run this script to generate schemas within ./generated_schemas folder. It will pull a subset of data from our dev
    Firestore installation to infer each schema.

    Make sure to have previously run `gcloud auth login` and `gcloud config set project juntochat-dev`.

    After generating the schemas, run update-views.sh to apply them to dev or production.
 */

const bigquery = new BigQuery();

function removeEmpty(obj) {
  return Object.fromEntries(Object.entries(obj).filter(([_, v]) => v != null));
}

async function runQuery(sql) {
    const options = {
        query: sql,
        location: 'US',
    };

    const [job] = await bigquery.createQueryJob(options);
    const [rows] = await job.getQueryResults();
    return rows;
}

function toSchema(input) {
    let data = removeEmpty(input);
    let schema = [];
    for (const field in data) {
        let fields;
        let value = data[field];
        let datatype;
        if (typeof value === "string"){
            datatype = 'string';
        } else if (typeof value === "number"){
            datatype = 'number';
        } else if (typeof value === "boolean"){
            datatype = 'boolean';
        } else if (typeof value === "object"){
            if (Array.isArray(value)){
                datatype = 'array';
            } else {
                if (value['_seconds'] !== undefined){
                    datatype = 'timestamp';
                } else {
                    datatype = 'map'
                    fields = toSchema(value);
                }
            }
        }
        schema.push({
            "name": field,
            "type": datatype,
            ...(fields && {"fields": fields})
        });
    }
    schema.sort((a, b) => a.name > b.name ? 1 : -1);
    return schema;
}

async function run() {
    const tables = await runQuery('SELECT * FROM `juntochat-dev`.`firestore_export`.INFORMATION_SCHEMA.TABLES;');
    const tableNames = tables
        .filter(t => t.table_type === "BASE TABLE" && t.table_schema === 'firestore_export' && t.table_name.endsWith("_raw_changelog"))
        .map(t => t.table_name);
    for await (const tableName of tableNames) {
        const rows = await runQuery(`SELECT * from \`juntochat-dev\`.\`firestore_export\`.\`${tableName}\` limit 10000`);
        let merged = rows.filter(r => r.data).map(r => JSON.parse(r.data)).reduce((a, b) => ({...a, ...b}), {});
        let schema = {
            "fields": toSchema(merged)
        };
        const baseTableName = tableName.replace('_raw_changelog', '');
        fs.writeFile(`./generated_schemas/${baseTableName}.json`, JSON.stringify(schema, null, 2)+"\n", err => {
          if (err) {
            console.error(err)
          }
        })
    }
}

run();
