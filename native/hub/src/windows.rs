use crate::common::Result;
use crate::messages::windows::{OptionFeatures, OptionalFeature, QueryOptionalFeature};
use wmi::{COMLibrary, WMIConnection};

pub async fn query_features() -> Result<()> {
    let mut rev = QueryOptionalFeature::get_dart_signal_receiver()?;
    while let Some(_) = rev.recv().await {
        let wmi_con = WMIConnection::new(COMLibrary::new().unwrap()).unwrap();
        let features: Vec<OptionalFeature> = wmi_con
            .raw_query(r#"SELECT * FROM Win32_OptionalFeature where name="VirtualMachinePlatform" OR name="Microsoft-Windows-Subsystem-Linux""#)
            .unwrap();
        OptionFeatures { features }.send_signal_to_dart()
    }
    Ok(())
}
