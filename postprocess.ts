// Vendored locally via deno.json + vendor/ (re-pin/re-vendor with ./vendor-flat.sh).
import { readCSV, writeCSV } from 'https://deno.land/x/flat@0.0.15/src/csv.ts'

// flat action runs on Deno, a Node competitor. Flat will pass in the downloaded filename as arg 0.
const filePath: string = Deno.args[0]

// Lazyquotes lets readCSV handle values containing line-endings inside quoted strings. 
const tribalLeaders: Record<string, any> = await readCSV(filePath, {lazyQuotes: true})

// custom compare function
function compare( a, b ) {
    if ( a["Tribe Full Name"] < b["Tribe Full Name"] ){
      return -1;
    }
    if ( a['Tribe Full Name'] > b['Tribe Full Name'] ){
      return 1;
    }
    return 0;
  }

// process each line
tribalLeaders.forEach(object => {
    // remove OBJECTID
    delete object['OBJECTID'];
    delete object['GlobalID'];

    //strip newlines from all but the last element
    for(const property in object) {
        if(property === 'y') {
            break;
        }
        object[property] = object[property].replace(/\r?\n|\r/g, '');
    }
 })

 // sort using custom compare function
tribalLeaders.sort(compare)

await writeCSV('./tribal-leaders.csv', tribalLeaders)

