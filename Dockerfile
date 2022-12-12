FROM python:3
WORKDIR /opt/
RUN pip3 --no-cache-dir install discord requests asyncio typing
RUN pip3 install revChatGPT --upgrade
COPY . .
CMD ["python", "ChatGPTdiscord.py"]
