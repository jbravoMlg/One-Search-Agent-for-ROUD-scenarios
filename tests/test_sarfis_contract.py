from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SARFIS = ROOT / "sarfis"


def test_sarfis_sources_and_gui_assets_are_present() -> None:
    expected = [
        SARFIS / "start_sarfis.m",
        SARFIS / "Matlab functions/GUI/GUI.m",
        SARFIS / "Matlab functions/GUI/GUI.fig",
        SARFIS / "Matlab functions/GUI/UMA.jpg",
        SARFIS / "Matlab functions/GUI/representarWaypointsROS.m",
        SARFIS / "Matlab functions/DEM/XYZread.m",
        SARFIS / "Matlab functions/DEM/XYZ2grid.m",
        SARFIS / "Matlab functions/GPX/GPSll2utm.m",
        SARFIS / "Matlab functions/GPX/GPSutm2ll.m",
        SARFIS / "Matlab functions/GPX/GPXGenerar.m",
    ]
    assert all(path.is_file() for path in expected)
    assert len(list((SARFIS / "Matlab functions").rglob("*.m"))) == 21


def test_sarfis_generated_artifacts_are_excluded() -> None:
    assert not (SARFIS / "resources/project").exists()
    assert not (SARFIS / "works/mex").exists()
    assert not list(SARFIS.rglob("*.db3"))


def test_sarfis_launcher_and_material_availability_contract() -> None:
    launcher = (SARFIS / "start_sarfis.m").read_text()
    availability = (SARFIS / "DEM files/README.md").read_text()
    ros_helper = (
        SARFIS / "Matlab functions/GUI/representarWaypointsROS.m"
    ).read_text()

    assert "addpath" in launcher
    assert "SARFIS:MissingDEM" in launcher
    assert "upon reasonable request" in availability
    assert ros_helper.startswith("function representarWaypointsROS()")
