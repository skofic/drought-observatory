# Data directory

This directory contains all the data used in the project. The directory is divided as follows:

- **download**: This directory contains the files downloaded from the [European Drought Observatory portal](https://drought.emergency.copernicus.eu/tumbo/edo/download/). *You must download one file per year*.
- **GeoTIFF**: This directory will cotain all unzipped files from *download*.
- **XYZ**: This directory will contain all files converted from GeoTIFF to XYZ format.

The data indicators are the following:

**Fraction of Absorbed Photosynthetically Active Radiation (FAPAN) Anomaly**
*Resolution*: 1 kilometer
*From GIS*: 0.04166666666999999796
*Descriptor GID*: `env_climate_fapan`

**Fraction of Absorbed Photosynthetically Active Radiation (FAPAR)**
*Resolution*: 1 kilometer
*From GIS*: 0.04166666666999999796
*Descriptor GID*: `env_climate_fapar`

**Combined Drought Indicator (CDI)**
*Resolution*: 5 kilometer
*From GIS*: 0.06350589 decimal degree
*Descriptor GID*: `env_climate_cdi`

**Soil Moisture Anomaly (SMA)**
*Resolution*: 5 kilometer
*From GIS*: 0.06350589 decimal degree
*Descriptor GID*: `env_climate_sma`

**Soil Moisture Index (SMI)**
*Resolution*: 5 kilometer
*From GIS*: 0.06350589 decimal degree
*Descriptor GID*: `env_climate_smi`

**GRACE Total Water Storage (TWS) Anomaly**
*Resolution*: 5 kilometer
*From GIS*: 0.06350589 decimal degree
*Descriptor GID*: `env_climate_tws`

**Heat and Cold Wave Index (HCWI)**
*Resolution*: 25 kilometer
*From GIS*: 0.25 decimal degree
*Descriptor GID*: `env_climate_hcwi`, `env_climate_hcwi_ano`, `env_climate_hcwi_min`, `env_climate_hcwi_max`
