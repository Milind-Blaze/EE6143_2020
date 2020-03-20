# Assignment3

In this assignment, the RRC messages present in TS 38.331 are encoded using the ASN1C ASN.1 compiler. This work primarily involves obtaining the ASN1C compiler, parsing TS 38.331 and then compiling the resulting .asn file.

- [Report](https://drive.google.com/file/d/1sZ57I_3me5Ksi9KHLSZWPt8D35-5KcHn/view?usp=sharing)
- [Compiled C files (according to BER)](https://drive.google.com/drive/folders/1y4V7ST1Tlh2EI-ZFrJmK96roSrJd0JYz?usp=sharing)

## Contents

### definitions.asn

The ASN file containing all the modules (3 of them) defined in TS 38.331 obtained by parsing it using the file TSscan.py. This is validated and compiled using the ASN1C ASN.1 compiler.

### TSscan.py

Python script to parse TS 38.331 and obtain all the RRC messages.

#### Usage

Run as 

```
python TSscan.py
```

Expects the file __"38331-f80.docx"__ to be present in the working directory. 

#### Output

- __definitions.txt__: A .txt file with all the ASN.1 definitions contained in TS 38.331   


## Useful links

- [ASN1C ASN.1 compiler](https://obj-sys.com/products/asn1c/index.php?gclid=EAIaIQobChMI07HPz7Wo6AIVTxOPCh08cgOOEAAYASAAEgLj7_D_BwE)
- [TS 38.331](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3197)
- [docxpy](https://pypi.org/project/docxpy/)