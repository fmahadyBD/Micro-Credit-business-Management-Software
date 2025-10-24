import { bootstrapApplication } from '@angular/platform-browser';
import { importProvidersFrom } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';

import { AppComponent } from './app/app.component';
import { ApiConfiguration } from './app/services/api-configuration';
import { appConfig } from './app/app.config';

bootstrapApplication(AppComponent, {
  ...appConfig,
  providers: [
    ...appConfig.providers || [],
    ApiConfiguration,                     // provide OpenAPI config
    importProvidersFrom(HttpClientModule) // provide HttpClient globally
  ]
})
.catch((err) => console.error(err));
