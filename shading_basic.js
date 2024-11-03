imp = IJ.getImage();
IJ.run(imp, "BaSiC ", "processing_stack=B2ROI1_03_1_1_GFP_corr.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate flat-field only (ignore dark-field)] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");
