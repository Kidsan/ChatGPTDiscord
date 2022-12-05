FROM python:3
WORKDIR /opt/
RUN pip3 --no-cache-dir install discord revChatGPT requests
COPY . .
CMD ["python", "ChatGPTdiscord.py"]
