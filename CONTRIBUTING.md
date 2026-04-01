# **Contributing to RRZT**

🟦 **Thank you for contributing!** To maintain project quality, please follow these guidelines.

---

## **1. Branching Strategy**

🟦 **Primary Branches**: `main` (Production), `develop` (Integration).  
🟦 **Feature Branches**: Create from `develop`, name as `feat/short-description-issue-N`.  
🟦 **Fix Branches**: Create from `develop`, name as `fix/short-description-issue-N`.  

---

## **2. Development Standards**

### **Conventional Commits**
🟩 Use [Conventional Commits](https://www.conventionalcommits.org/).  
🟩 Format: `type(scope): description (Resolves #N)`.  
🟩 Common Types: `feat`, `fix`, `docs`, `improve`, `config`, `ci`.  

### **PowerShell & Scripting**
🟩 Maintain TUI precision and padding for all PowerShell scripts (`deploy.ps1`, `verify.ps1`).  
🟩 Use ANSI escape sequences for colorization.  

### **Documentation**
🟩 All **H2** and **H3** headers must be bold.  
🟩 Use only approved shapes: 🟦, 🟩, 🟥, 🔸, 🔹, 💠, 🔄.  

---

## **3. Submission Process**

💠 **Step 1**: Open an **Issue** on GitLab to discuss your change.  
💠 **Step 2**: Create a Merge Request (MR) targeting the **`develop`** branch.  
💠 **Step 3**: Ensure all changes are verified via `verify.ps1`.  
💠 **Step 4**: The MR will be reviewed and merged after approval.  

---

## **4. Code of Conduct**

🟦 Be professional, concise, and technically grounded.  
🟦 Focus on **intent** and **technical rationale**.  
