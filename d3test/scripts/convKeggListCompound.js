/**
 * Function for converting the raw KEGG REST API response to list compound data
 * into a JSON.  This is useful because, when requesting the list, it returns a
 * tab-delimited file containing the KEGG Compound ID in the first column, and
 * a semi-colon separated list of the associated names in the second column.
 *
 * Thus, this can be converted into a JSON of the format:
 * {"idKegg": "cpd:C00001", "nameKegg": ["H2O", "Water"]}
 *
 * I won't force lowercase at this stage, I'll leave that for the other ops
 * (which have already been written, and do just that).  I also won't trim the
 * `cpd:` prefix, but that may be necessary.  With or without the prefix, it's
 * a unique identifier in KEGG.
 *
 * @param {String} raw String of raw text read from the file.
 * @return {Array} Array of Objects, each containing the KEGG Compound ID (with
 * prefix ^cpd:(?=C\d{5})) and the associated names.
 */
function convKeggListCompound(raw) {
  // Split up the raw text
  let data = raw.split(/\n/).filter(x => x !== '').map(r => r.split(/\t/));
  // Operate on the data
  return data.map(d => {
    // For each entry, index 0 is the ID, and index 1 is the
    // semicolon-delimited name list, which needs to be split.
    return {"idKegg": d[0], "nameKegg": d[1].split(/; /)};
  });
}