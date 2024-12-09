# Import libraries
from flask import Flask, request, jsonify, Response
import pandas as pd
import json

# APP parameters
app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True

# Load the annotated file into memory as a Pandas DataFrame for querying
ANNOTATED_FILE = "results/annotated.hg19_multianno.edited.txt"
annotated_data = pd.read_csv(ANNOTATED_FILE, sep="\t")

# Handles string characters (e.g. dots '.') in AF COL (ABraOM)
annotated_data['abraom_freq'] = annotated_data['abraom_freq'].replace('.', '10').astype(float)

# Explicitly sets the COL data types
annotated_data['Chr'] = annotated_data['Chr'].astype(str)
annotated_data['Start'] = annotated_data['Start'].astype(int)
annotated_data['End'] = annotated_data['End'].astype(int)
annotated_data['Ref'] = annotated_data['Ref'].astype(str)
annotated_data['Alt'] = annotated_data['Alt'].astype(str)
annotated_data['abraom_freq'] = annotated_data['abraom_freq'].astype(float)
annotated_data['DP'] = annotated_data['DP'].astype(int)

@app.route('/query', methods=['GET'])
def query_variant():
    """
    Query variants by chromosome, start and end positions, reference, and alternate alleles.
    OR
    Allele frequency (e.g. gnomAD or ABraOM - Brazilian)
    OR
    Depth (DP)
    Example query:
    /query?chr=1&start=123456&end=123456&ref=A&alt=T
    """

    # Extract query parameters and ensuring correct data type
    chromosome = request.args.get('Chr')
    start = request.args.get('Start', type=int)
    end = request.args.get('End', type=int)
    ref_allele = request.args.get('Ref')
    alt_allele = request.args.get('Alt')
    allele_freq = request.args.get('abraom_freq', type=float)  # In this case I'm choosing ABraOM, since we are in Brazil
    depth = request.args.get('DP', type=int)  # From VCF, kept in the beginning of the pipeline

    # Query by variant (chromosome, start, end, ref, alt)
    if chromosome and start and end and ref_allele and alt_allele:
        result = annotated_data[
            (annotated_data['Chr'] == chromosome) &  # 1 (chromosome)
            (annotated_data['Start'] == start) &  # 324822 (start)
            (annotated_data['End'] == end) &  # 324822 (end)
            (annotated_data['Ref'] == ref_allele) &  # A (ref_allele)
            (annotated_data['Alt'] == alt_allele)  # T (alt_allele)
        ]

    # Query by allele frequency
    elif allele_freq is not None:
        result = annotated_data[annotated_data["abraom_freq"] <= allele_freq]

    # Query by depth
    elif depth is not None:
        result = annotated_data[annotated_data["DP"] >= depth]

    # If no valid query parameters are provided, return an error message
    else:
        return jsonify({"Error": "Invalid query parameters. Please provide a valid variant: (Chr, Start, End, Ref, Alt) OR abraom_freq (Allele Freq.) OR DP (Depth)."}), 400

    # Return the result as JSON
    if result.empty:
        return jsonify({"Message": "No matching variant found"}), 404
    else:
        # Replace missing values with "N/A" and format column names
        cleaned_result = result.fillna("N/A")  # Replace missing values
        cleaned_result.columns = [col.replace("_", " ") for col in cleaned_result.columns]  # Format column names

        # Organize data into structured JSON format
        final_result = []
        for _, row in cleaned_result.iterrows():
            variant = {
                "variant": {
                    "Chromosome": row["Chr"],
                    "Start": row["Start"],
                    "End": row["End"],
                    "Reference allele": row["Ref"],
                    "Alternate allele": row["Alt"]
                },
                "annotations": {
                    key: row[key]
                    for key in row.index
                    if key not in ["Chr", "Start", "End", "Ref", "Alt"]
                }
            }
            final_result.append(variant)

        # Use json.dumps with indent for multi-line formatting
        pretty_result = json.dumps(final_result, indent=4)

    # Return results in JSON format
    return Response(pretty_result, mimetype="application/json"), 200

if __name__ == '__main__':
    app.run(debug=False, host="0.0.0.0", port=5000)
