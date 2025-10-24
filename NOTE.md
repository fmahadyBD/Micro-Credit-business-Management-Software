
During development, when using **OpenAPI-generated services** (e.g., `UsersService`) in **standalone Angular components**, the following error was encountered:

```
NullInjectorError: R3InjectorError(Standalone[_AdminDashboardComponent])[_UsersService -> _UsersService -> _HttpClient -> _HttpClient]: 
  NullInjectorError: No provider for _HttpClient!
```

**Cause:**

* `UsersService` depends on both `HttpClient` and `ApiConfiguration`.
* In standalone components, Angular requires these providers to be **declared in the parent injector** or **provided globally**.
* Simply importing `HttpClientModule` inside the component itself is **not sufficient**.

**Solution:**

* Provide `HttpClientModule` and `ApiConfiguration` **globally** in `main.ts` using `importProvidersFrom()` and `providers`.
* This allows OpenAPI services to be injected into **any standalone component** without DI errors.

---

### Backend: Update OpenAPI Version

Update the Springdoc OpenAPI dependency to ensure compatibility:

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.1.0</version>
</dependency>
```

> **Note:** Upgrading Springdoc OpenAPI resolves potential Swagger generation issues and ensures compatibility with the latest OpenAPI 3 specification.

---

### Frontend: Update OpenAPI Generator

Update the Angular OpenAPI generator to generate services automatically:

```bash
npm uninstall ng-openapi-gen
npm install ng-openapi-gen@0.53.0 --save-dev
```

> **Note:** After updating, Angular services for all endpoints will be generated automatically and fully typed. This ensures easier integration with your components.

---

### Additional Notes

* After updating OpenAPI versions and regenerating services, you can initialize **all users as test users** for development and UI testing.
* Ensure `HttpClientModule` and `ApiConfiguration` are provided either:

  * **Globally** in `bootstrapApplication()` in `main.ts`
  * Or in the **parent standalone component** that injects the OpenAPI service.
* Without these providers, standalone Angular components cannot inject OpenAPI services, resulting in `NullInjectorError`.

---
