#!/bin/bash

# Build merged
npm run merge || exit 1
wc -l ./zbw_hcpr_cp.abap

# Deploy artifacts
git clone https://github.com/pawelwiejkut/bw_hcpr_cp.git
cp zbw_hcpr_cp.abap bw_hcpr_cp/last_build/zbw_hcpr_cp.abap
cd bw_hcpr_cp

# Commit
git status
git config user.email "ci@pawelwiejkut.net"
git config user.name "CI"
git add last_build/zbw_trfn_tester.abap
git commit -m "CI build [skip ci]" || exit 1
git push -q https://$GITHUB_API_KEY@github.com/pawelwiejkut/bw_trfn_tester.git 
