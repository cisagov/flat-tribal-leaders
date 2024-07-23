import { readCSV, writeCSV, removeFile } from 'https://deno.land/x/flat@0.0.15/mod.ts' // replace with latest library https://deno.land/x/flat@0.0.x/mod.ts

const filePath: string = Deno.args[0]

// flat runs on Deno, a Node competitor. Flat will pass in the downloaded filename as arg 0.
const tribalLeaders: Record<string, any> = await readCSV(filePath, {lazyQuotes: true})

// custom compare function
function compare( a, b ) {
    if ( a["Tribe Full Name"] < b["Tribe Full Name"] ){
      return -1;
    }
    if ( a['Tribe Full Name'] > b['Tribe Last Name'] ){
      return 1;
    }
    return 0;
  }

// remove OBJECTID
tribalLeaders.forEach(object => {
    delete object['OBJECTID'];
 })

tribalLeaders.sort(compare)

await removeFile(filePath)

await writeCSV(tribalLeaders, './tribal-leaders.csv')

