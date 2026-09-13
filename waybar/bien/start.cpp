#include <QApplication>
#include <QMainWindow>
#include <QWidget>
#include <QLineEdit>
#include <QListWidget>
#include <QPushButton>
#include <QPainter>
#include <QLabel>
#include <QProcess>
#include <QPixmap>
#include <QDir>
#include <QStringList>
#include <QSettings>
#include <QStandardPaths>


class TransparentWindow : public QMainWindow {
    
public:
    //Window create
    TransparentWindow(QWidget *parent=nullptr) : QMainWindow(parent){
        setWindowFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
        setAttribute(Qt::WA_TranslucentBackground);
        setFixedSize(500, 550);
        this->setObjectName("Window");
        this->setStyleSheet(
            "QMainWindow#Window {"
            "   background-color: qlineargradient("
                    "spread:pad," 
                    "x1:0, y1:0, "
                    "x2:0, y2:1, "
                    "stop:0 rgba(107, 131, 154, 230),  "
                    "stop:0.4 rgba(66, 88, 110, 230),   "
                    "stop:1 rgba(43, 61, 79, 240)       "
                ");"
                "border-top-right-radius: 5px;"
                "border-bottom-right-radius: 5px;"
            "}"

            "QPushButton {"
                "text-align: left;"
                "font-family: 'Segoe UI', sans-serif;"
                "font-size: 13px;"
                "color: rgba(255, 255, 255, 1);"
                "background-color: transparent;"
                "border: 1px solid transparent;"
                "border-radius: 3px;"
            "}"

            "QPushButton:hover {"
            "    background: qlineargradient(x1:0, y1:0, x2:0, y2:1, "
            "                stop:0 rgba(255, 255, 255, 0.4), "
            "                stop:0.5 rgba(255, 255, 255, 0.15), "
            "                stop:0.51 rgba(0, 0, 0, 0.05), "
            "                stop:1 rgba(255, 255, 255, 0.2));"
            "    border: 1px solid rgba(255, 255, 255, 0.45);"
            "    border-radius: 4px;"
            "    color: white;" 
            "}"

            "QPushButton#SpecialButton{"
            "    background: qlineargradient(x1:0, y1:0, x2:0, y2:1, "
            "                stop:0 rgba(255, 255, 255, 0.4), "
            "                stop:0.5 rgba(255, 255, 255, 0.15), "
            "                stop:0.51 rgba(0, 0, 0, 0.05), "
            "                stop:1 rgba(255, 255, 255, 0.2));"
            "    border: 1px solid rgba(0, 0, 0, 0.45);"
            "    border-top-left-radius: 2px;"
            "    border-bottom-left-radius: 2px;"
            "    border-top-right-radius: 0px;"
            "    border-bottom-right-radius: 0px;"
            "    color: white;" 
            "    text-align: center"
            "}"

            "QPushButton#SpecialButton:hover{"
            "    background: qlineargradient(x1:0, y1:0, x2:0, y2:1, "
                    "stop:0 rgba(255, 255, 255, 0.6), "
                    "stop:0.5 rgba(255, 255, 255, 0.3), "
                    "stop:0.51 rgba(255, 255, 255, 0.1), "
                    "stop:1 rgba(255, 255, 255, 0.4));"
               "border-color: rgba(255, 255, 255, 0.7);"
            "}"

            "QPushButton#SpecialButton1 {"
            "    background: qlineargradient(x1:0, y1:0, x2:0, y2:1, "
            "                stop:0 rgba(255, 255, 255, 0.4), "
            "                stop:0.5 rgba(255, 255, 255, 0.15), "
            "                stop:0.51 rgba(0, 0, 0, 0.05), "
            "                stop:1 rgba(255, 255, 255, 0.2));"
            "    border: 1px solid rgba(0, 0, 0, 0.45);"
            "    border-left: none;"
            "    border-top-left-radius: 0px;"
            "    border-bottom-left-radius: 0px;"
            "    border-top-right-radius: 2px;"
            "    border-bottom-right-radius: 2px;"
            "    color: white;"
            "    text-align: center;"
            "    font-size: 8px"
            "}"
            
            "QPushButton#SpecialButton1:hover{"
            "    background: qlineargradient(x1:0, y1:0, x2:0, y2:1, "
                    "stop:0 rgba(255, 255, 255, 0.6), "
                    "stop:0.5 rgba(255, 255, 255, 0.3), "
                    "stop:0.51 rgba(255, 255, 255, 0.1), "
                    "stop:1 rgba(255, 255, 255, 0.4));"
               "border-color: rgba(255, 255, 255, 0.7);"
            "}"
        );

        //adding photo profile
        QString appDir = QCoreApplication::applicationDirPath();
        QLabel *imageLabel = new QLabel(this);
        QPixmap pixmap(appDir + "/sprites/flower.png");
        imageLabel->setPixmap(pixmap.scaled(100, 100, Qt::KeepAspectRatio));
        imageLabel->setGeometry(350, -8, 100, 100);
        
        
        QWidget *powerContainer = new QWidget(this);
        powerContainer->setGeometry(313, 516, 180, 25);
        powerContainer->setObjectName("PowerContainer");

        //creating button
        QPushButton *powerbutton = new QPushButton("Завершение работы", powerContainer);
        powerbutton->setGeometry(0, 0, 140, 23);
        powerbutton->setObjectName("SpecialButton");


        //creating list button
        listButton = new QPushButton("►", powerContainer);
        listButton->setGeometry(140, 0, 25, 23);
        listButton->setObjectName("SpecialButton1");
        
        
        
        //creating directory filter
        QDir dir("/usr/share/applications/");
        QStringList filters;
        filters << "*.desktop";
        dir.setNameFilters(filters);
        dir.setFilter(QDir::Files);
        QStringList files = dir.entryList();
        appsListWidget = new QListWidget(this);
        appsListWidget->setGeometry(5, 5, 300, 512);
        
        //fing names and icons
        for (const QString &fileName : files) {
            QString absolutePath = dir.absoluteFilePath(fileName);
            QSettings desktopFile(absolutePath, QSettings::IniFormat);
            

            desktopFile.beginGroup("Desktop Entry");
            //desktopFile.setIniCodec("UTF-8");


            QString appName = desktopFile.value("Name").toString();
            QString iconName = desktopFile.value("Icon").toString();
            QString linkName = desktopFile.value("Exec").toString();
            desktopFile.endGroup();
            
            QListWidgetItem *desktopList = new QListWidgetItem(appsListWidget);
            desktopList->setText(appName);
            desktopList->setIcon(QIcon::fromTheme(iconName));
            desktopList->setData(Qt::UserRole, absolutePath);
            desktopList->setData(Qt::UserRole + 1, linkName);
        };
        

        //adding right panel button
        QPushButton *userButton = new QPushButton("Степан", this);
        userButton->setGeometry(320, 105, 175, 30);
        QPushButton *documentButton = new QPushButton("Документы", this);
        documentButton->setGeometry(320, 140, 175, 30);
        QPushButton *picturesButton = new QPushButton("Изображения", this);
        picturesButton->setGeometry(320, 175, 175, 30);
        QPushButton *computerButton = new QPushButton("Компьютер", this);
        computerButton->setGeometry(320, 210, 175, 30);
        QPushButton *terminalButton = new QPushButton("Терминал", this);
        terminalButton->setGeometry(320, 245, 175, 30);
        QPushButton *fileButton = new QPushButton("Dolphin", this);
        fileButton->setGeometry(320, 280, 175, 30);
        QPushButton *wofiButton = new QPushButton("Приложения", this);
        wofiButton->setGeometry(320, 315, 175, 30);
        QPushButton *browserButton = new QPushButton("Браузер", this);
        browserButton->setGeometry(320, 350, 175, 30);

        //creating search line
        QLineEdit *search = new QLineEdit(this);
        search->setGeometry(5, 517, 300, 25);
        search->addAction(QIcon::fromTheme("edit-find"), QLineEdit::TrailingPosition);
        search->setStyleSheet(
            "QLineEdit {"
            "   border: 3px solid #b9c4da;"
            "   background-color: #ffffff;"      
            "   color: #000000;"
            "   padding-left: 5px;"
            "}"
        );
        search->setPlaceholderText("Найти программы и файлы");
        
        

        //poweroff button
        QObject::connect(powerbutton, &QPushButton::clicked, this, &TransparentWindow::buttonPush);
        
        //right buttons
        QObject::connect(userButton, &QPushButton::clicked, this, &TransparentWindow::userbuttonPush);
        QObject::connect(documentButton, &QPushButton::clicked, this, &TransparentWindow::documentbuttonPush);
        QObject::connect(picturesButton, &QPushButton::clicked, this, &TransparentWindow::picturesbuttonPush);
        QObject::connect(computerButton, &QPushButton::clicked, this, &TransparentWindow::computerbuttonPush);
        QObject::connect(terminalButton, &QPushButton::clicked, this, &TransparentWindow::terminalbuttonPush);
        QObject::connect(fileButton, &QPushButton::clicked, this, &TransparentWindow::filebuttonPush);
        QObject::connect(wofiButton, &QPushButton::clicked, this, &TransparentWindow::wofibuttonPush);
        QObject::connect(browserButton, &QPushButton::clicked, this, &TransparentWindow::browserbuttonPush);

        //search filter line
        QObject::connect(search, &QLineEdit::textChanged, this, &TransparentWindow::filterApps);

        //open app function
        QObject::connect(appsListWidget, &QListWidget::itemClicked, this, &TransparentWindow::openApp);
        
        //list button
        QObject::connect(listButton, &QPushButton::clicked, this, &TransparentWindow::listbuttonPush);
        buttonsList = new QListWidget(this);
        buttonsList->setWindowFlags(Qt::ToolTip | Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
        buttonsList->setAttribute(Qt::WA_DeleteOnClose);
        
        buttonsList->resize(150, 100);
        
        buttonsList->addItem("Сменить пользователя");
        buttonsList->addItem("Выйти из системы");
        buttonsList->addItem("Блокировать");
        buttonsList->addItem("Перезагрузка");
        buttonsList->addItem("Сон");
        
        QObject::connect(buttonsList, &QListWidget::itemClicked, this, &TransparentWindow::DropMenu);

    }

protected:
    //poweroff button
    void buttonPush() {
        QProcess::startDetached("systemctl", {"poweroff"});
    }

    void userbuttonPush() {
        QProcess::startDetached("thunar", {QDir::homePath()});
        close();
    }
    
    void documentbuttonPush() {
        QString docsPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
        QProcess::startDetached("thunar", {docsPath});
        close();
    }
    
    void picturesbuttonPush() {
        QString picPath = QDir::homePath() + "/Pictures/screenshots";
        QProcess::startDetached("thunar", {picPath});
        close();
    }
    
    void computerbuttonPush() {
        QProcess::startDetached("thunar", {"/"});
        close();
    }
    
    void terminalbuttonPush() {
        QProcess::startDetached("alacritty");
        close();
    }

    void filebuttonPush() {
        QProcess::startDetached("dolphin");
        close();
    }

    void wofibuttonPush() {
        QProcess::startDetached("wofi");
        close();
    }

    void browserbuttonPush() {
        QProcess::startDetached("firefox");
        close();
    }

    void listbuttonPush() {
        if (buttonsList->isVisible()) {
            buttonsList->hide();
        } else {
        QPoint globalBtnPos = listButton->mapToGlobal(QPoint(150, 28));
        int x = globalBtnPos.x() - buttonsList->width() + listButton->width();
        int y = globalBtnPos.y() - buttonsList->height() - 5;
        buttonsList->move(x, y);
        buttonsList->show();
        buttonsList->raise();
        }
    }


    void DropMenu(QListWidgetItem *item) {
        buttonsList->hide();
        if (!item) return;
        
        if (item->text() == "Сменить пользователя") {
            QProcess::startDetached("loginctl", {"terminate-user"});
        } else if (item->text() == "Выйти из системы") {
            QProcess::startDetached("loginctl", {"terminate-user", ""});
        } else if (item->text() == "Блокировать") {
            QProcess::startDetached("hyprlock", {});
        } else if (item->text() == "Перезагрузка") {
            QProcess::startDetached("systemctl", {"reboot"});
        } else if (item->text() == "Сон") {
            QProcess::startDetached("systemctl", {"suspend"});
        }
    }

    //search line filter function
    void filterApps(const QString &text) {
        if (appsListWidget == nullptr) {
            return; 
        }
        
        for (int i = 0; i < appsListWidget->count(); ++i){
            QListWidgetItem *item = appsListWidget->item(i);
            bool matches = item->text().contains(text, Qt::CaseInsensitive);
            item->setHidden(!matches);
        }
    }

    //open app function
    void openApp(QListWidgetItem *item) {
        if (!item) return;
        
        QString execCommand = item->data(Qt::UserRole + 1).toString();
        execCommand = execCommand.remove("%u").remove("%U").remove("%f").remove("%F").trimmed();
        if (!execCommand.isEmpty()) {
            QProcess::startDetached(execCommand);
            close();
        }
    }
    void paintEvent(QPaintEvent *event) override {
        QStyleOption opt;
        opt.initFrom(this);
        QPainter p(this);
        style()->drawPrimitive(QStyle::PE_Widget, &opt, &p, this);
        QMainWindow::paintEvent(event);
    }
private:
    QPushButton *listButton;
    QListWidget *buttonsList;
    QListWidget *appsListWidget;
    //QProcess *process;
};

//main function for launch
int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    TransparentWindow window;
    //window.resize(200, 200);
    window.show();
    return app.exec();
}
