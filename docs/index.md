# 🧠 Run Konveyor AI in OpenShift Dev Spaces with VS Code Extension

This guide walks you through running Konveyor AI using **OpenShift Dev Spaces** with VS Code as an IDE.  
You'll analyze and modernize a real Java application using the Kai VS Code extension in a Red Hat Dev Spaces workspace.

---

## 🧰 Prerequisites

- Access to an OpenShift cluster with **Dev Spaces enabled**
- [`podman`](https://podman.io/getting-started/installation) installed locally
- A [Quay.io](https://quay.io) container registry account
- Kai `.vsix` file from [Konveyor AI Releases](https://github.com/konveyor/editor-extensions/releases)
- OpenAI credentials to use GPT-4o or a similar LLM

---

## 🏗️ Step 1: Build the Custom Dev Spaces Image

Create a `Containerfile` (based on Red Hat UBI for Dev Spaces):

```Dockerfile
# Use official Dev Spaces base 
#FROM registry.redhat.io/devspaces/udi-rhel9:3.18-2.1741779985
FROM quay.io/devfile/universal-developer-image:ubi9-latest

USER root

# Avoid flaky mirrors, timeouts, or zchunk checksum mismatches
RUN echo "fastestmirror=True" >> /etc/dnf/dnf.conf && \
    echo "skip_if_unavailable=True" >> /etc/dnf/dnf.conf && \
    echo "zchunk=False" >> /etc/dnf/dnf.conf

# Install dependencies required by Konveyor AI + typical tools
RUN dnf clean all && \
    dnf install -y --nobest --allowerasing \
        python3.12 python3.12-devel \
        java-17-openjdk-devel \
        nodejs maven \
        unzip git curl zsh \
        gcc make glibc-devel libffi-devel openssl-devel \
    && dnf clean all

# Add Kai extension from GitHub release
RUN curl -L -o /konveyor.vsix https://github.com/konveyor/editor-extensions/releases/download/v0.0.13/konveyor-v0.0.13.vsix
ENV DEFAULT_EXTENSIONS=/konveyor.vsix


ENV DEFAULT_EXTENSIONS=/konveyor-v0.0.13.vsix    

USER user
```

### 🛠️ Build & Push

```bash
podman build -t quay.io/<your-username>/kai-devspaces:latest .
podman push quay.io/<your-username>/kai-devspaces:latest
```

---

## 📦 Step 2: Create `devfile.yaml`

```yaml
schemaVersion: 2.2.0
metadata:
  name: kai-devspaces
components:
  - name: kai-dev-container
    container:
      image: quay.io/<your-username>/kai-devspaces:latest
      memoryLimit: 8Gi
```

Launch a new Dev Spaces workspace using this `devfile.yaml`.

---





<img width="1221" alt="Screenshot 2025-03-26 at 4 40 04 PM" src="https://github.com/user-attachments/assets/fb1bc6f7-5b82-4394-82e1-26b2182827eb" />


<img width="1500" alt="Screenshot 2025-03-26 at 4 36 30 PM" src="https://github.com/user-attachments/assets/1cd9e106-dca6-42d6-8262-3631ca8d801d" />


<img width="1511" alt="Screenshot 2025-03-26 at 4 42 59 PM" src="https://github.com/user-attachments/assets/a4f437fb-467f-42c0-9200-d7dfa1ce13ea" />


## 📂 Step 3: Clone the Example Codebase

In your Dev Spaces terminal:

```bash
git clone https://github.com/rrbanda/coolstore.git
cd coolstore
```

---

## ⚙️ Step 4: Configure the Extension specific details

### Ensure `.vscode/settings.json` includes:

```json
{
  "konveyor.analysis.useDefaultRulesets": true,
  "konveyor.analysis.labelSelector": "(konveyor.io/target=jakarta-ee || konveyor.io/target=openjdk11 || konveyor.io/target=openjdk17) || (discovery)"
}
```

### Confgure the LLM 

### Configure source and target dependencies 


https://github.com/user-attachments/assets/3e498252-f620-4985-bac7-e22b17819ec6





---

## 🚀 Step 5: Run the Analysis

1. Open the Command Palette (`Cmd+Shift+P` or `Ctrl+Shift+P`)
2. Run: **Konveyor: Run Analysis**
3. Once the RPC server is initialized, navigate to the **Konveyor Analysis View** and run the analysis

![Run Analysis](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/run_analysis.png)

---

## 🧾 View and Filter Issues

The Konveyor Analysis View will list issues by file. Use the issue panel to filter and navigate easily:

![Analysis View](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/konveyor_analysis_view.png)

Lost the panel? Use the Command Palette and reopen the view:

![Reopen Panel](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/konveyor_analysis_view_1.png)

---

## 🛠️ Apply Fixes

### Change Import Namespaces

Search for a file like `InventoryEntity.java`, click the fix icon, and choose the effort level (Low/Medium/High):

![Request Fix](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/request_fix.png)

Review the generated suggestion:

![Resolution Details 1](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/resolution_details1.png)
![Resolution Details 2](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/resolution_details2.png)

Use the Diff view to inspect and accept:

![Change Import](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/change_import_namespaces.png)

---

## 📐 Apply Advanced Fixes

### Modify Scope (CDI Beans)

Fix files like `CatalogService.java`:

![CDI Fix 1](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/cdi_bean_requirement1.png)
![CDI Fix 2](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/cdi_bean_requirement2.png)

### EJB Replacements

For `ShippingService.java`:

![EJB REST Replace](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/shippingService.png)

---

### JMS to SmallRye

Resolve JMS issues by selecting **Medium** effort:

![JMS Migration](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/jmstosmallrye.png)
![JMS Fix 1](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/jmstosmllrye1.png)
![JMS Fix 2](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/jmstosmallrye2.png)
![JMS Fix 3](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/jmstosmallrye3.png)
![JMS Fix 4](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/jmstosmallrye4.png)

---

## 💡 Agentic Workflow

Understand how Kai orchestrates fixes behind the scenes:

![Agentic Flow](https://github.com/konveyor/kai/raw/main/docs/scenarios/javaEE_to_quarkus/images/agentic-flow.png)

---

## ✅ Expected Behavior

- Incident suggestions appear
- You can select effort level and apply changes
- Logs are saved in `.vscode/konveyor-logs/`
- You can validate using:

```bash
mvn clean install && mvn compile
```

---

## 📁 Example Project Structure

```bash
coolstore/
├── .vscode/
│   └── settings.json
├── pom.xml
├── src/
└── ...
```

---

## 📎 References

- 🔗 [Konveyor AI Editor Extension](https://github.com/konveyor/editor-extensions)
- 🧪 [Coolstore Demo App](https://github.com/rrbanda/coolstore)
- 🧭 [Full Kai Migration Demo (JavaEE → Quarkus)](https://github.com/konveyor/kai/blob/main/docs/scenarios/javaEE_to_quarkus/README.md)
- 💬 [Join Konveyor on Slack](https://konveyor.io/join-slack)

---
```

Let me know if you want this pushed into your GitHub repo or saved as a file.
