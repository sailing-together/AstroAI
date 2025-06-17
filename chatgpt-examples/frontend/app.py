import streamlit as st
import requests

API_URL = "http://localhost:8000/horoscope"

st.title("AstroAI — Daily Horoscope")

name = st.text_input("Enter your name:")
birthdate = st.date_input("Enter your birthdate:")

if st.button("Generate Horoscope"):
    if name and birthdate:
        with st.spinner("Generating your horoscope..."):
            payload = {
                "name": name,
                "birthdate": birthdate.strftime("%Y-%m-%d")
            }
            response = requests.post(API_URL, json=payload)
            if response.status_code == 200:
                result = response.json()["result"]
                st.markdown(result)
            else:
                st.error("Failed to generate result.")
    else:
        st.warning("Please fill out all fields.")
